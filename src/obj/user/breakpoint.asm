
obj/user/breakpoint.debug：     文件格式 elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	83 ec 10             	sub    $0x10,%esp
  800041:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800044:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800047:	e8 dd 00 00 00       	call   800129 <sys_getenvid>
  80004c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800051:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800054:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800059:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005e:	85 db                	test   %ebx,%ebx
  800060:	7e 07                	jle    800069 <libmain+0x30>
		binaryname = argv[0];
  800062:	8b 06                	mov    (%esi),%eax
  800064:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800069:	89 74 24 04          	mov    %esi,0x4(%esp)
  80006d:	89 1c 24             	mov    %ebx,(%esp)
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 07 00 00 00       	call   800081 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	5b                   	pop    %ebx
  80007e:	5e                   	pop    %esi
  80007f:	5d                   	pop    %ebp
  800080:	c3                   	ret    

00800081 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800081:	55                   	push   %ebp
  800082:	89 e5                	mov    %esp,%ebp
  800084:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800087:	e8 5a 05 00 00       	call   8005e6 <close_all>
	sys_env_destroy(0);
  80008c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800093:	e8 3f 00 00 00       	call   8000d7 <sys_env_destroy>
}
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ab:	89 c3                	mov    %eax,%ebx
  8000ad:	89 c7                	mov    %eax,%edi
  8000af:	89 c6                	mov    %eax,%esi
  8000b1:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000be:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c8:	89 d1                	mov    %edx,%ecx
  8000ca:	89 d3                	mov    %edx,%ebx
  8000cc:	89 d7                	mov    %edx,%edi
  8000ce:	89 d6                	mov    %edx,%esi
  8000d0:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8000e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ed:	89 cb                	mov    %ecx,%ebx
  8000ef:	89 cf                	mov    %ecx,%edi
  8000f1:	89 ce                	mov    %ecx,%esi
  8000f3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	7e 28                	jle    800121 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000fd:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800104:	00 
  800105:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  80010c:	00 
  80010d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800114:	00 
  800115:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  80011c:	e8 55 10 00 00       	call   801176 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800121:	83 c4 2c             	add    $0x2c,%esp
  800124:	5b                   	pop    %ebx
  800125:	5e                   	pop    %esi
  800126:	5f                   	pop    %edi
  800127:	5d                   	pop    %ebp
  800128:	c3                   	ret    

00800129 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	57                   	push   %edi
  80012d:	56                   	push   %esi
  80012e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80012f:	ba 00 00 00 00       	mov    $0x0,%edx
  800134:	b8 02 00 00 00       	mov    $0x2,%eax
  800139:	89 d1                	mov    %edx,%ecx
  80013b:	89 d3                	mov    %edx,%ebx
  80013d:	89 d7                	mov    %edx,%edi
  80013f:	89 d6                	mov    %edx,%esi
  800141:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800143:	5b                   	pop    %ebx
  800144:	5e                   	pop    %esi
  800145:	5f                   	pop    %edi
  800146:	5d                   	pop    %ebp
  800147:	c3                   	ret    

00800148 <sys_yield>:

void
sys_yield(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	57                   	push   %edi
  80014c:	56                   	push   %esi
  80014d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014e:	ba 00 00 00 00       	mov    $0x0,%edx
  800153:	b8 0b 00 00 00       	mov    $0xb,%eax
  800158:	89 d1                	mov    %edx,%ecx
  80015a:	89 d3                	mov    %edx,%ebx
  80015c:	89 d7                	mov    %edx,%edi
  80015e:	89 d6                	mov    %edx,%esi
  800160:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800162:	5b                   	pop    %ebx
  800163:	5e                   	pop    %esi
  800164:	5f                   	pop    %edi
  800165:	5d                   	pop    %ebp
  800166:	c3                   	ret    

00800167 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	57                   	push   %edi
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
  80016d:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800170:	be 00 00 00 00       	mov    $0x0,%esi
  800175:	b8 04 00 00 00       	mov    $0x4,%eax
  80017a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017d:	8b 55 08             	mov    0x8(%ebp),%edx
  800180:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800183:	89 f7                	mov    %esi,%edi
  800185:	cd 30                	int    $0x30
	if(check && ret > 0)
  800187:	85 c0                	test   %eax,%eax
  800189:	7e 28                	jle    8001b3 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80018f:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800196:	00 
  800197:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  80019e:	00 
  80019f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001a6:	00 
  8001a7:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  8001ae:	e8 c3 0f 00 00       	call   801176 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b3:	83 c4 2c             	add    $0x2c,%esp
  8001b6:	5b                   	pop    %ebx
  8001b7:	5e                   	pop    %esi
  8001b8:	5f                   	pop    %edi
  8001b9:	5d                   	pop    %ebp
  8001ba:	c3                   	ret    

008001bb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	57                   	push   %edi
  8001bf:	56                   	push   %esi
  8001c0:	53                   	push   %ebx
  8001c1:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8001c4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001da:	85 c0                	test   %eax,%eax
  8001dc:	7e 28                	jle    800206 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001de:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001e2:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001e9:	00 
  8001ea:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  8001f1:	00 
  8001f2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001f9:	00 
  8001fa:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  800201:	e8 70 0f 00 00       	call   801176 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800206:	83 c4 2c             	add    $0x2c,%esp
  800209:	5b                   	pop    %ebx
  80020a:	5e                   	pop    %esi
  80020b:	5f                   	pop    %edi
  80020c:	5d                   	pop    %ebp
  80020d:	c3                   	ret    

0080020e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020e:	55                   	push   %ebp
  80020f:	89 e5                	mov    %esp,%ebp
  800211:	57                   	push   %edi
  800212:	56                   	push   %esi
  800213:	53                   	push   %ebx
  800214:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800217:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021c:	b8 06 00 00 00       	mov    $0x6,%eax
  800221:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800224:	8b 55 08             	mov    0x8(%ebp),%edx
  800227:	89 df                	mov    %ebx,%edi
  800229:	89 de                	mov    %ebx,%esi
  80022b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80022d:	85 c0                	test   %eax,%eax
  80022f:	7e 28                	jle    800259 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800231:	89 44 24 10          	mov    %eax,0x10(%esp)
  800235:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80023c:	00 
  80023d:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  800244:	00 
  800245:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80024c:	00 
  80024d:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  800254:	e8 1d 0f 00 00       	call   801176 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800259:	83 c4 2c             	add    $0x2c,%esp
  80025c:	5b                   	pop    %ebx
  80025d:	5e                   	pop    %esi
  80025e:	5f                   	pop    %edi
  80025f:	5d                   	pop    %ebp
  800260:	c3                   	ret    

00800261 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800261:	55                   	push   %ebp
  800262:	89 e5                	mov    %esp,%ebp
  800264:	57                   	push   %edi
  800265:	56                   	push   %esi
  800266:	53                   	push   %ebx
  800267:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80026a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026f:	b8 08 00 00 00       	mov    $0x8,%eax
  800274:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800277:	8b 55 08             	mov    0x8(%ebp),%edx
  80027a:	89 df                	mov    %ebx,%edi
  80027c:	89 de                	mov    %ebx,%esi
  80027e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800280:	85 c0                	test   %eax,%eax
  800282:	7e 28                	jle    8002ac <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800284:	89 44 24 10          	mov    %eax,0x10(%esp)
  800288:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80028f:	00 
  800290:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  800297:	00 
  800298:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80029f:	00 
  8002a0:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  8002a7:	e8 ca 0e 00 00       	call   801176 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002ac:	83 c4 2c             	add    $0x2c,%esp
  8002af:	5b                   	pop    %ebx
  8002b0:	5e                   	pop    %esi
  8002b1:	5f                   	pop    %edi
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	57                   	push   %edi
  8002b8:	56                   	push   %esi
  8002b9:	53                   	push   %ebx
  8002ba:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8002bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c2:	b8 09 00 00 00       	mov    $0x9,%eax
  8002c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cd:	89 df                	mov    %ebx,%edi
  8002cf:	89 de                	mov    %ebx,%esi
  8002d1:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002d3:	85 c0                	test   %eax,%eax
  8002d5:	7e 28                	jle    8002ff <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002db:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002e2:	00 
  8002e3:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  8002ea:	00 
  8002eb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002f2:	00 
  8002f3:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  8002fa:	e8 77 0e 00 00       	call   801176 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ff:	83 c4 2c             	add    $0x2c,%esp
  800302:	5b                   	pop    %ebx
  800303:	5e                   	pop    %esi
  800304:	5f                   	pop    %edi
  800305:	5d                   	pop    %ebp
  800306:	c3                   	ret    

00800307 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	57                   	push   %edi
  80030b:	56                   	push   %esi
  80030c:	53                   	push   %ebx
  80030d:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800310:	bb 00 00 00 00       	mov    $0x0,%ebx
  800315:	b8 0a 00 00 00       	mov    $0xa,%eax
  80031a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031d:	8b 55 08             	mov    0x8(%ebp),%edx
  800320:	89 df                	mov    %ebx,%edi
  800322:	89 de                	mov    %ebx,%esi
  800324:	cd 30                	int    $0x30
	if(check && ret > 0)
  800326:	85 c0                	test   %eax,%eax
  800328:	7e 28                	jle    800352 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80032a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80032e:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800335:	00 
  800336:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  80033d:	00 
  80033e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800345:	00 
  800346:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  80034d:	e8 24 0e 00 00       	call   801176 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800352:	83 c4 2c             	add    $0x2c,%esp
  800355:	5b                   	pop    %ebx
  800356:	5e                   	pop    %esi
  800357:	5f                   	pop    %edi
  800358:	5d                   	pop    %ebp
  800359:	c3                   	ret    

0080035a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80035a:	55                   	push   %ebp
  80035b:	89 e5                	mov    %esp,%ebp
  80035d:	57                   	push   %edi
  80035e:	56                   	push   %esi
  80035f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800360:	be 00 00 00 00       	mov    $0x0,%esi
  800365:	b8 0c 00 00 00       	mov    $0xc,%eax
  80036a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80036d:	8b 55 08             	mov    0x8(%ebp),%edx
  800370:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800373:	8b 7d 14             	mov    0x14(%ebp),%edi
  800376:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800378:	5b                   	pop    %ebx
  800379:	5e                   	pop    %esi
  80037a:	5f                   	pop    %edi
  80037b:	5d                   	pop    %ebp
  80037c:	c3                   	ret    

0080037d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80037d:	55                   	push   %ebp
  80037e:	89 e5                	mov    %esp,%ebp
  800380:	57                   	push   %edi
  800381:	56                   	push   %esi
  800382:	53                   	push   %ebx
  800383:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800386:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800390:	8b 55 08             	mov    0x8(%ebp),%edx
  800393:	89 cb                	mov    %ecx,%ebx
  800395:	89 cf                	mov    %ecx,%edi
  800397:	89 ce                	mov    %ecx,%esi
  800399:	cd 30                	int    $0x30
	if(check && ret > 0)
  80039b:	85 c0                	test   %eax,%eax
  80039d:	7e 28                	jle    8003c7 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80039f:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003a3:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003aa:	00 
  8003ab:	c7 44 24 08 8a 20 80 	movl   $0x80208a,0x8(%esp)
  8003b2:	00 
  8003b3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003ba:	00 
  8003bb:	c7 04 24 a7 20 80 00 	movl   $0x8020a7,(%esp)
  8003c2:	e8 af 0d 00 00       	call   801176 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003c7:	83 c4 2c             	add    $0x2c,%esp
  8003ca:	5b                   	pop    %ebx
  8003cb:	5e                   	pop    %esi
  8003cc:	5f                   	pop    %edi
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    
  8003cf:	90                   	nop

008003d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8003db:	c1 e8 0c             	shr    $0xc,%eax
}
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003f0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003f5:	5d                   	pop    %ebp
  8003f6:	c3                   	ret    

008003f7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003f7:	55                   	push   %ebp
  8003f8:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003fa:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8003ff:	a8 01                	test   $0x1,%al
  800401:	74 34                	je     800437 <fd_alloc+0x40>
  800403:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800408:	a8 01                	test   $0x1,%al
  80040a:	74 32                	je     80043e <fd_alloc+0x47>
  80040c:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
		fd = INDEX2FD(i);
  800411:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800413:	89 c2                	mov    %eax,%edx
  800415:	c1 ea 16             	shr    $0x16,%edx
  800418:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80041f:	f6 c2 01             	test   $0x1,%dl
  800422:	74 1f                	je     800443 <fd_alloc+0x4c>
  800424:	89 c2                	mov    %eax,%edx
  800426:	c1 ea 0c             	shr    $0xc,%edx
  800429:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800430:	f6 c2 01             	test   $0x1,%dl
  800433:	75 1a                	jne    80044f <fd_alloc+0x58>
  800435:	eb 0c                	jmp    800443 <fd_alloc+0x4c>
		fd = INDEX2FD(i);
  800437:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80043c:	eb 05                	jmp    800443 <fd_alloc+0x4c>
  80043e:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
			*fd_store = fd;
  800443:	8b 45 08             	mov    0x8(%ebp),%eax
  800446:	89 08                	mov    %ecx,(%eax)
			return 0;
  800448:	b8 00 00 00 00       	mov    $0x0,%eax
  80044d:	eb 1a                	jmp    800469 <fd_alloc+0x72>
  80044f:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800454:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800459:	75 b6                	jne    800411 <fd_alloc+0x1a>
		}
	}
	*fd_store = 0;
  80045b:	8b 45 08             	mov    0x8(%ebp),%eax
  80045e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800464:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800469:	5d                   	pop    %ebp
  80046a:	c3                   	ret    

0080046b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80046b:	55                   	push   %ebp
  80046c:	89 e5                	mov    %esp,%ebp
  80046e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800471:	83 f8 1f             	cmp    $0x1f,%eax
  800474:	77 36                	ja     8004ac <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800476:	c1 e0 0c             	shl    $0xc,%eax
  800479:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80047e:	89 c2                	mov    %eax,%edx
  800480:	c1 ea 16             	shr    $0x16,%edx
  800483:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80048a:	f6 c2 01             	test   $0x1,%dl
  80048d:	74 24                	je     8004b3 <fd_lookup+0x48>
  80048f:	89 c2                	mov    %eax,%edx
  800491:	c1 ea 0c             	shr    $0xc,%edx
  800494:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80049b:	f6 c2 01             	test   $0x1,%dl
  80049e:	74 1a                	je     8004ba <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a3:	89 02                	mov    %eax,(%edx)
	return 0;
  8004a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004aa:	eb 13                	jmp    8004bf <fd_lookup+0x54>
		return -E_INVAL;
  8004ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004b1:	eb 0c                	jmp    8004bf <fd_lookup+0x54>
		return -E_INVAL;
  8004b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004b8:	eb 05                	jmp    8004bf <fd_lookup+0x54>
  8004ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004bf:	5d                   	pop    %ebp
  8004c0:	c3                   	ret    

008004c1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004c1:	55                   	push   %ebp
  8004c2:	89 e5                	mov    %esp,%ebp
  8004c4:	53                   	push   %ebx
  8004c5:	83 ec 14             	sub    $0x14,%esp
  8004c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8004ce:	39 05 04 30 80 00    	cmp    %eax,0x803004
  8004d4:	75 1e                	jne    8004f4 <dev_lookup+0x33>
  8004d6:	eb 0e                	jmp    8004e6 <dev_lookup+0x25>
	for (i = 0; devtab[i]; i++)
  8004d8:	b8 20 30 80 00       	mov    $0x803020,%eax
  8004dd:	eb 0c                	jmp    8004eb <dev_lookup+0x2a>
  8004df:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  8004e4:	eb 05                	jmp    8004eb <dev_lookup+0x2a>
  8004e6:	b8 04 30 80 00       	mov    $0x803004,%eax
			*dev = devtab[i];
  8004eb:	89 03                	mov    %eax,(%ebx)
			return 0;
  8004ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f2:	eb 38                	jmp    80052c <dev_lookup+0x6b>
		if (devtab[i]->dev_id == dev_id) {
  8004f4:	39 05 20 30 80 00    	cmp    %eax,0x803020
  8004fa:	74 dc                	je     8004d8 <dev_lookup+0x17>
  8004fc:	39 05 3c 30 80 00    	cmp    %eax,0x80303c
  800502:	74 db                	je     8004df <dev_lookup+0x1e>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800504:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80050a:	8b 52 48             	mov    0x48(%edx),%edx
  80050d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800511:	89 54 24 04          	mov    %edx,0x4(%esp)
  800515:	c7 04 24 b8 20 80 00 	movl   $0x8020b8,(%esp)
  80051c:	e8 4e 0d 00 00       	call   80126f <cprintf>
	*dev = 0;
  800521:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800527:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80052c:	83 c4 14             	add    $0x14,%esp
  80052f:	5b                   	pop    %ebx
  800530:	5d                   	pop    %ebp
  800531:	c3                   	ret    

00800532 <fd_close>:
{
  800532:	55                   	push   %ebp
  800533:	89 e5                	mov    %esp,%ebp
  800535:	56                   	push   %esi
  800536:	53                   	push   %ebx
  800537:	83 ec 20             	sub    $0x20,%esp
  80053a:	8b 75 08             	mov    0x8(%ebp),%esi
  80053d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800540:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800543:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800547:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80054d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800550:	89 04 24             	mov    %eax,(%esp)
  800553:	e8 13 ff ff ff       	call   80046b <fd_lookup>
  800558:	85 c0                	test   %eax,%eax
  80055a:	78 05                	js     800561 <fd_close+0x2f>
	    || fd != fd2)
  80055c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80055f:	74 0c                	je     80056d <fd_close+0x3b>
		return (must_exist ? r : 0);
  800561:	84 db                	test   %bl,%bl
  800563:	ba 00 00 00 00       	mov    $0x0,%edx
  800568:	0f 44 c2             	cmove  %edx,%eax
  80056b:	eb 3f                	jmp    8005ac <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80056d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800570:	89 44 24 04          	mov    %eax,0x4(%esp)
  800574:	8b 06                	mov    (%esi),%eax
  800576:	89 04 24             	mov    %eax,(%esp)
  800579:	e8 43 ff ff ff       	call   8004c1 <dev_lookup>
  80057e:	89 c3                	mov    %eax,%ebx
  800580:	85 c0                	test   %eax,%eax
  800582:	78 16                	js     80059a <fd_close+0x68>
		if (dev->dev_close)
  800584:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800587:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80058a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80058f:	85 c0                	test   %eax,%eax
  800591:	74 07                	je     80059a <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  800593:	89 34 24             	mov    %esi,(%esp)
  800596:	ff d0                	call   *%eax
  800598:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  80059a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80059e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005a5:	e8 64 fc ff ff       	call   80020e <sys_page_unmap>
	return r;
  8005aa:	89 d8                	mov    %ebx,%eax
}
  8005ac:	83 c4 20             	add    $0x20,%esp
  8005af:	5b                   	pop    %ebx
  8005b0:	5e                   	pop    %esi
  8005b1:	5d                   	pop    %ebp
  8005b2:	c3                   	ret    

008005b3 <close>:

int
close(int fdnum)
{
  8005b3:	55                   	push   %ebp
  8005b4:	89 e5                	mov    %esp,%ebp
  8005b6:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c3:	89 04 24             	mov    %eax,(%esp)
  8005c6:	e8 a0 fe ff ff       	call   80046b <fd_lookup>
  8005cb:	89 c2                	mov    %eax,%edx
  8005cd:	85 d2                	test   %edx,%edx
  8005cf:	78 13                	js     8005e4 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8005d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8005d8:	00 
  8005d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005dc:	89 04 24             	mov    %eax,(%esp)
  8005df:	e8 4e ff ff ff       	call   800532 <fd_close>
}
  8005e4:	c9                   	leave  
  8005e5:	c3                   	ret    

008005e6 <close_all>:

void
close_all(void)
{
  8005e6:	55                   	push   %ebp
  8005e7:	89 e5                	mov    %esp,%ebp
  8005e9:	53                   	push   %ebx
  8005ea:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005ed:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005f2:	89 1c 24             	mov    %ebx,(%esp)
  8005f5:	e8 b9 ff ff ff       	call   8005b3 <close>
	for (i = 0; i < MAXFD; i++)
  8005fa:	83 c3 01             	add    $0x1,%ebx
  8005fd:	83 fb 20             	cmp    $0x20,%ebx
  800600:	75 f0                	jne    8005f2 <close_all+0xc>
}
  800602:	83 c4 14             	add    $0x14,%esp
  800605:	5b                   	pop    %ebx
  800606:	5d                   	pop    %ebp
  800607:	c3                   	ret    

00800608 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800608:	55                   	push   %ebp
  800609:	89 e5                	mov    %esp,%ebp
  80060b:	57                   	push   %edi
  80060c:	56                   	push   %esi
  80060d:	53                   	push   %ebx
  80060e:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800611:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800614:	89 44 24 04          	mov    %eax,0x4(%esp)
  800618:	8b 45 08             	mov    0x8(%ebp),%eax
  80061b:	89 04 24             	mov    %eax,(%esp)
  80061e:	e8 48 fe ff ff       	call   80046b <fd_lookup>
  800623:	89 c2                	mov    %eax,%edx
  800625:	85 d2                	test   %edx,%edx
  800627:	0f 88 e1 00 00 00    	js     80070e <dup+0x106>
		return r;
	close(newfdnum);
  80062d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800630:	89 04 24             	mov    %eax,(%esp)
  800633:	e8 7b ff ff ff       	call   8005b3 <close>

	newfd = INDEX2FD(newfdnum);
  800638:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80063b:	c1 e3 0c             	shl    $0xc,%ebx
  80063e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800644:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800647:	89 04 24             	mov    %eax,(%esp)
  80064a:	e8 91 fd ff ff       	call   8003e0 <fd2data>
  80064f:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  800651:	89 1c 24             	mov    %ebx,(%esp)
  800654:	e8 87 fd ff ff       	call   8003e0 <fd2data>
  800659:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80065b:	89 f0                	mov    %esi,%eax
  80065d:	c1 e8 16             	shr    $0x16,%eax
  800660:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800667:	a8 01                	test   $0x1,%al
  800669:	74 43                	je     8006ae <dup+0xa6>
  80066b:	89 f0                	mov    %esi,%eax
  80066d:	c1 e8 0c             	shr    $0xc,%eax
  800670:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800677:	f6 c2 01             	test   $0x1,%dl
  80067a:	74 32                	je     8006ae <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80067c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800683:	25 07 0e 00 00       	and    $0xe07,%eax
  800688:	89 44 24 10          	mov    %eax,0x10(%esp)
  80068c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800690:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800697:	00 
  800698:	89 74 24 04          	mov    %esi,0x4(%esp)
  80069c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006a3:	e8 13 fb ff ff       	call   8001bb <sys_page_map>
  8006a8:	89 c6                	mov    %eax,%esi
  8006aa:	85 c0                	test   %eax,%eax
  8006ac:	78 3e                	js     8006ec <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006b1:	89 c2                	mov    %eax,%edx
  8006b3:	c1 ea 0c             	shr    $0xc,%edx
  8006b6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006bd:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006c3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006c7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006d2:	00 
  8006d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006de:	e8 d8 fa ff ff       	call   8001bb <sys_page_map>
  8006e3:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  8006e5:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006e8:	85 f6                	test   %esi,%esi
  8006ea:	79 22                	jns    80070e <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  8006ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006f7:	e8 12 fb ff ff       	call   80020e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800700:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800707:	e8 02 fb ff ff       	call   80020e <sys_page_unmap>
	return r;
  80070c:	89 f0                	mov    %esi,%eax
}
  80070e:	83 c4 3c             	add    $0x3c,%esp
  800711:	5b                   	pop    %ebx
  800712:	5e                   	pop    %esi
  800713:	5f                   	pop    %edi
  800714:	5d                   	pop    %ebp
  800715:	c3                   	ret    

00800716 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	53                   	push   %ebx
  80071a:	83 ec 24             	sub    $0x24,%esp
  80071d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800720:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800723:	89 44 24 04          	mov    %eax,0x4(%esp)
  800727:	89 1c 24             	mov    %ebx,(%esp)
  80072a:	e8 3c fd ff ff       	call   80046b <fd_lookup>
  80072f:	89 c2                	mov    %eax,%edx
  800731:	85 d2                	test   %edx,%edx
  800733:	78 6d                	js     8007a2 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800735:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800738:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073f:	8b 00                	mov    (%eax),%eax
  800741:	89 04 24             	mov    %eax,(%esp)
  800744:	e8 78 fd ff ff       	call   8004c1 <dev_lookup>
  800749:	85 c0                	test   %eax,%eax
  80074b:	78 55                	js     8007a2 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80074d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800750:	8b 50 08             	mov    0x8(%eax),%edx
  800753:	83 e2 03             	and    $0x3,%edx
  800756:	83 fa 01             	cmp    $0x1,%edx
  800759:	75 23                	jne    80077e <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80075b:	a1 04 40 80 00       	mov    0x804004,%eax
  800760:	8b 40 48             	mov    0x48(%eax),%eax
  800763:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800767:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076b:	c7 04 24 f9 20 80 00 	movl   $0x8020f9,(%esp)
  800772:	e8 f8 0a 00 00       	call   80126f <cprintf>
		return -E_INVAL;
  800777:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077c:	eb 24                	jmp    8007a2 <read+0x8c>
	}
	if (!dev->dev_read)
  80077e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800781:	8b 52 08             	mov    0x8(%edx),%edx
  800784:	85 d2                	test   %edx,%edx
  800786:	74 15                	je     80079d <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800788:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80078b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80078f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800792:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800796:	89 04 24             	mov    %eax,(%esp)
  800799:	ff d2                	call   *%edx
  80079b:	eb 05                	jmp    8007a2 <read+0x8c>
		return -E_NOT_SUPP;
  80079d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8007a2:	83 c4 24             	add    $0x24,%esp
  8007a5:	5b                   	pop    %ebx
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	57                   	push   %edi
  8007ac:	56                   	push   %esi
  8007ad:	53                   	push   %ebx
  8007ae:	83 ec 1c             	sub    $0x1c,%esp
  8007b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007b4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007b7:	85 f6                	test   %esi,%esi
  8007b9:	74 33                	je     8007ee <readn+0x46>
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c0:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007c5:	89 f2                	mov    %esi,%edx
  8007c7:	29 c2                	sub    %eax,%edx
  8007c9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8007cd:	03 45 0c             	add    0xc(%ebp),%eax
  8007d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d4:	89 3c 24             	mov    %edi,(%esp)
  8007d7:	e8 3a ff ff ff       	call   800716 <read>
		if (m < 0)
  8007dc:	85 c0                	test   %eax,%eax
  8007de:	78 1b                	js     8007fb <readn+0x53>
			return m;
		if (m == 0)
  8007e0:	85 c0                	test   %eax,%eax
  8007e2:	74 11                	je     8007f5 <readn+0x4d>
	for (tot = 0; tot < n; tot += m) {
  8007e4:	01 c3                	add    %eax,%ebx
  8007e6:	89 d8                	mov    %ebx,%eax
  8007e8:	39 f3                	cmp    %esi,%ebx
  8007ea:	72 d9                	jb     8007c5 <readn+0x1d>
  8007ec:	eb 0b                	jmp    8007f9 <readn+0x51>
  8007ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f3:	eb 06                	jmp    8007fb <readn+0x53>
  8007f5:	89 d8                	mov    %ebx,%eax
  8007f7:	eb 02                	jmp    8007fb <readn+0x53>
  8007f9:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8007fb:	83 c4 1c             	add    $0x1c,%esp
  8007fe:	5b                   	pop    %ebx
  8007ff:	5e                   	pop    %esi
  800800:	5f                   	pop    %edi
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	53                   	push   %ebx
  800807:	83 ec 24             	sub    $0x24,%esp
  80080a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80080d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800810:	89 44 24 04          	mov    %eax,0x4(%esp)
  800814:	89 1c 24             	mov    %ebx,(%esp)
  800817:	e8 4f fc ff ff       	call   80046b <fd_lookup>
  80081c:	89 c2                	mov    %eax,%edx
  80081e:	85 d2                	test   %edx,%edx
  800820:	78 68                	js     80088a <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800822:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800825:	89 44 24 04          	mov    %eax,0x4(%esp)
  800829:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80082c:	8b 00                	mov    (%eax),%eax
  80082e:	89 04 24             	mov    %eax,(%esp)
  800831:	e8 8b fc ff ff       	call   8004c1 <dev_lookup>
  800836:	85 c0                	test   %eax,%eax
  800838:	78 50                	js     80088a <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80083a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80083d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800841:	75 23                	jne    800866 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800843:	a1 04 40 80 00       	mov    0x804004,%eax
  800848:	8b 40 48             	mov    0x48(%eax),%eax
  80084b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80084f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800853:	c7 04 24 15 21 80 00 	movl   $0x802115,(%esp)
  80085a:	e8 10 0a 00 00       	call   80126f <cprintf>
		return -E_INVAL;
  80085f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800864:	eb 24                	jmp    80088a <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800866:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800869:	8b 52 0c             	mov    0xc(%edx),%edx
  80086c:	85 d2                	test   %edx,%edx
  80086e:	74 15                	je     800885 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800870:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800873:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800877:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80087e:	89 04 24             	mov    %eax,(%esp)
  800881:	ff d2                	call   *%edx
  800883:	eb 05                	jmp    80088a <write+0x87>
		return -E_NOT_SUPP;
  800885:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80088a:	83 c4 24             	add    $0x24,%esp
  80088d:	5b                   	pop    %ebx
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <seek>:

int
seek(int fdnum, off_t offset)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800896:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800899:	89 44 24 04          	mov    %eax,0x4(%esp)
  80089d:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a0:	89 04 24             	mov    %eax,(%esp)
  8008a3:	e8 c3 fb ff ff       	call   80046b <fd_lookup>
  8008a8:	85 c0                	test   %eax,%eax
  8008aa:	78 0e                	js     8008ba <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8008ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8008b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ba:	c9                   	leave  
  8008bb:	c3                   	ret    

008008bc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	53                   	push   %ebx
  8008c0:	83 ec 24             	sub    $0x24,%esp
  8008c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008cd:	89 1c 24             	mov    %ebx,(%esp)
  8008d0:	e8 96 fb ff ff       	call   80046b <fd_lookup>
  8008d5:	89 c2                	mov    %eax,%edx
  8008d7:	85 d2                	test   %edx,%edx
  8008d9:	78 61                	js     80093c <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008e5:	8b 00                	mov    (%eax),%eax
  8008e7:	89 04 24             	mov    %eax,(%esp)
  8008ea:	e8 d2 fb ff ff       	call   8004c1 <dev_lookup>
  8008ef:	85 c0                	test   %eax,%eax
  8008f1:	78 49                	js     80093c <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008f6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008fa:	75 23                	jne    80091f <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008fc:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800901:	8b 40 48             	mov    0x48(%eax),%eax
  800904:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800908:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090c:	c7 04 24 d8 20 80 00 	movl   $0x8020d8,(%esp)
  800913:	e8 57 09 00 00       	call   80126f <cprintf>
		return -E_INVAL;
  800918:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80091d:	eb 1d                	jmp    80093c <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80091f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800922:	8b 52 18             	mov    0x18(%edx),%edx
  800925:	85 d2                	test   %edx,%edx
  800927:	74 0e                	je     800937 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800929:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800930:	89 04 24             	mov    %eax,(%esp)
  800933:	ff d2                	call   *%edx
  800935:	eb 05                	jmp    80093c <ftruncate+0x80>
		return -E_NOT_SUPP;
  800937:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  80093c:	83 c4 24             	add    $0x24,%esp
  80093f:	5b                   	pop    %ebx
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	53                   	push   %ebx
  800946:	83 ec 24             	sub    $0x24,%esp
  800949:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80094c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80094f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800953:	8b 45 08             	mov    0x8(%ebp),%eax
  800956:	89 04 24             	mov    %eax,(%esp)
  800959:	e8 0d fb ff ff       	call   80046b <fd_lookup>
  80095e:	89 c2                	mov    %eax,%edx
  800960:	85 d2                	test   %edx,%edx
  800962:	78 52                	js     8009b6 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800964:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800967:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80096e:	8b 00                	mov    (%eax),%eax
  800970:	89 04 24             	mov    %eax,(%esp)
  800973:	e8 49 fb ff ff       	call   8004c1 <dev_lookup>
  800978:	85 c0                	test   %eax,%eax
  80097a:	78 3a                	js     8009b6 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  80097c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80097f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800983:	74 2c                	je     8009b1 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800985:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800988:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80098f:	00 00 00 
	stat->st_isdir = 0;
  800992:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800999:	00 00 00 
	stat->st_dev = dev;
  80099c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8009a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009a9:	89 14 24             	mov    %edx,(%esp)
  8009ac:	ff 50 14             	call   *0x14(%eax)
  8009af:	eb 05                	jmp    8009b6 <fstat+0x74>
		return -E_NOT_SUPP;
  8009b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8009b6:	83 c4 24             	add    $0x24,%esp
  8009b9:	5b                   	pop    %ebx
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	56                   	push   %esi
  8009c0:	53                   	push   %ebx
  8009c1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009c4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009cb:	00 
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	89 04 24             	mov    %eax,(%esp)
  8009d2:	e8 af 01 00 00       	call   800b86 <open>
  8009d7:	89 c3                	mov    %eax,%ebx
  8009d9:	85 db                	test   %ebx,%ebx
  8009db:	78 1b                	js     8009f8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8009dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e4:	89 1c 24             	mov    %ebx,(%esp)
  8009e7:	e8 56 ff ff ff       	call   800942 <fstat>
  8009ec:	89 c6                	mov    %eax,%esi
	close(fd);
  8009ee:	89 1c 24             	mov    %ebx,(%esp)
  8009f1:	e8 bd fb ff ff       	call   8005b3 <close>
	return r;
  8009f6:	89 f0                	mov    %esi,%eax
}
  8009f8:	83 c4 10             	add    $0x10,%esp
  8009fb:	5b                   	pop    %ebx
  8009fc:	5e                   	pop    %esi
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	56                   	push   %esi
  800a03:	53                   	push   %ebx
  800a04:	83 ec 10             	sub    $0x10,%esp
  800a07:	89 c6                	mov    %eax,%esi
  800a09:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800a0b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a12:	75 11                	jne    800a25 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a14:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a1b:	e8 30 13 00 00       	call   801d50 <ipc_find_env>
  800a20:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a25:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a2c:	00 
  800a2d:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a34:	00 
  800a35:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a39:	a1 00 40 80 00       	mov    0x804000,%eax
  800a3e:	89 04 24             	mov    %eax,(%esp)
  800a41:	e8 c2 12 00 00       	call   801d08 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a46:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a4d:	00 
  800a4e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a59:	e8 4e 12 00 00       	call   801cac <ipc_recv>
}
  800a5e:	83 c4 10             	add    $0x10,%esp
  800a61:	5b                   	pop    %ebx
  800a62:	5e                   	pop    %esi
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	53                   	push   %ebx
  800a69:	83 ec 14             	sub    $0x14,%esp
  800a6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a72:	8b 40 0c             	mov    0xc(%eax),%eax
  800a75:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7f:	b8 05 00 00 00       	mov    $0x5,%eax
  800a84:	e8 76 ff ff ff       	call   8009ff <fsipc>
  800a89:	89 c2                	mov    %eax,%edx
  800a8b:	85 d2                	test   %edx,%edx
  800a8d:	78 2b                	js     800aba <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a8f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800a96:	00 
  800a97:	89 1c 24             	mov    %ebx,(%esp)
  800a9a:	e8 2c 0e 00 00       	call   8018cb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a9f:	a1 80 50 80 00       	mov    0x805080,%eax
  800aa4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800aaa:	a1 84 50 80 00       	mov    0x805084,%eax
  800aaf:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ab5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aba:	83 c4 14             	add    $0x14,%esp
  800abd:	5b                   	pop    %ebx
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <devfile_flush>:
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac9:	8b 40 0c             	mov    0xc(%eax),%eax
  800acc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800ad1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad6:	b8 06 00 00 00       	mov    $0x6,%eax
  800adb:	e8 1f ff ff ff       	call   8009ff <fsipc>
}
  800ae0:	c9                   	leave  
  800ae1:	c3                   	ret    

00800ae2 <devfile_read>:
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
  800ae7:	83 ec 10             	sub    $0x10,%esp
  800aea:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800aed:	8b 45 08             	mov    0x8(%ebp),%eax
  800af0:	8b 40 0c             	mov    0xc(%eax),%eax
  800af3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800af8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800afe:	ba 00 00 00 00       	mov    $0x0,%edx
  800b03:	b8 03 00 00 00       	mov    $0x3,%eax
  800b08:	e8 f2 fe ff ff       	call   8009ff <fsipc>
  800b0d:	89 c3                	mov    %eax,%ebx
  800b0f:	85 c0                	test   %eax,%eax
  800b11:	78 6a                	js     800b7d <devfile_read+0x9b>
	assert(r <= n);
  800b13:	39 c6                	cmp    %eax,%esi
  800b15:	73 24                	jae    800b3b <devfile_read+0x59>
  800b17:	c7 44 24 0c 32 21 80 	movl   $0x802132,0xc(%esp)
  800b1e:	00 
  800b1f:	c7 44 24 08 39 21 80 	movl   $0x802139,0x8(%esp)
  800b26:	00 
  800b27:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  800b2e:	00 
  800b2f:	c7 04 24 4e 21 80 00 	movl   $0x80214e,(%esp)
  800b36:	e8 3b 06 00 00       	call   801176 <_panic>
	assert(r <= PGSIZE);
  800b3b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b40:	7e 24                	jle    800b66 <devfile_read+0x84>
  800b42:	c7 44 24 0c 59 21 80 	movl   $0x802159,0xc(%esp)
  800b49:	00 
  800b4a:	c7 44 24 08 39 21 80 	movl   $0x802139,0x8(%esp)
  800b51:	00 
  800b52:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  800b59:	00 
  800b5a:	c7 04 24 4e 21 80 00 	movl   $0x80214e,(%esp)
  800b61:	e8 10 06 00 00       	call   801176 <_panic>
	memmove(buf, &fsipcbuf, r);
  800b66:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b6a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b71:	00 
  800b72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b75:	89 04 24             	mov    %eax,(%esp)
  800b78:	e8 49 0f 00 00       	call   801ac6 <memmove>
}
  800b7d:	89 d8                	mov    %ebx,%eax
  800b7f:	83 c4 10             	add    $0x10,%esp
  800b82:	5b                   	pop    %ebx
  800b83:	5e                   	pop    %esi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <open>:
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	53                   	push   %ebx
  800b8a:	83 ec 24             	sub    $0x24,%esp
  800b8d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800b90:	89 1c 24             	mov    %ebx,(%esp)
  800b93:	e8 d8 0c 00 00       	call   801870 <strlen>
  800b98:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b9d:	7f 60                	jg     800bff <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  800b9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ba2:	89 04 24             	mov    %eax,(%esp)
  800ba5:	e8 4d f8 ff ff       	call   8003f7 <fd_alloc>
  800baa:	89 c2                	mov    %eax,%edx
  800bac:	85 d2                	test   %edx,%edx
  800bae:	78 54                	js     800c04 <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  800bb0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bb4:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800bbb:	e8 0b 0d 00 00       	call   8018cb <strcpy>
	fsipcbuf.open.req_omode = mode;
  800bc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc3:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800bc8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bcb:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd0:	e8 2a fe ff ff       	call   8009ff <fsipc>
  800bd5:	89 c3                	mov    %eax,%ebx
  800bd7:	85 c0                	test   %eax,%eax
  800bd9:	79 17                	jns    800bf2 <open+0x6c>
		fd_close(fd, 0);
  800bdb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800be2:	00 
  800be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800be6:	89 04 24             	mov    %eax,(%esp)
  800be9:	e8 44 f9 ff ff       	call   800532 <fd_close>
		return r;
  800bee:	89 d8                	mov    %ebx,%eax
  800bf0:	eb 12                	jmp    800c04 <open+0x7e>
	return fd2num(fd);
  800bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bf5:	89 04 24             	mov    %eax,(%esp)
  800bf8:	e8 d3 f7 ff ff       	call   8003d0 <fd2num>
  800bfd:	eb 05                	jmp    800c04 <open+0x7e>
		return -E_BAD_PATH;
  800bff:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  800c04:	83 c4 24             	add    $0x24,%esp
  800c07:	5b                   	pop    %ebx
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    
  800c0a:	66 90                	xchg   %ax,%ax
  800c0c:	66 90                	xchg   %ax,%ax
  800c0e:	66 90                	xchg   %ax,%ax

00800c10 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
  800c15:	83 ec 10             	sub    $0x10,%esp
  800c18:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1e:	89 04 24             	mov    %eax,(%esp)
  800c21:	e8 ba f7 ff ff       	call   8003e0 <fd2data>
  800c26:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800c28:	c7 44 24 04 65 21 80 	movl   $0x802165,0x4(%esp)
  800c2f:	00 
  800c30:	89 1c 24             	mov    %ebx,(%esp)
  800c33:	e8 93 0c 00 00       	call   8018cb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800c38:	8b 46 04             	mov    0x4(%esi),%eax
  800c3b:	2b 06                	sub    (%esi),%eax
  800c3d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800c43:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c4a:	00 00 00 
	stat->st_dev = &devpipe;
  800c4d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c54:	30 80 00 
	return 0;
}
  800c57:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5c:	83 c4 10             	add    $0x10,%esp
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	53                   	push   %ebx
  800c67:	83 ec 14             	sub    $0x14,%esp
  800c6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c6d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c71:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c78:	e8 91 f5 ff ff       	call   80020e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c7d:	89 1c 24             	mov    %ebx,(%esp)
  800c80:	e8 5b f7 ff ff       	call   8003e0 <fd2data>
  800c85:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c90:	e8 79 f5 ff ff       	call   80020e <sys_page_unmap>
}
  800c95:	83 c4 14             	add    $0x14,%esp
  800c98:	5b                   	pop    %ebx
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <_pipeisclosed>:
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	57                   	push   %edi
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
  800ca1:	83 ec 2c             	sub    $0x2c,%esp
  800ca4:	89 c6                	mov    %eax,%esi
  800ca6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  800ca9:	a1 04 40 80 00       	mov    0x804004,%eax
  800cae:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800cb1:	89 34 24             	mov    %esi,(%esp)
  800cb4:	e8 df 10 00 00       	call   801d98 <pageref>
  800cb9:	89 c7                	mov    %eax,%edi
  800cbb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cbe:	89 04 24             	mov    %eax,(%esp)
  800cc1:	e8 d2 10 00 00       	call   801d98 <pageref>
  800cc6:	39 c7                	cmp    %eax,%edi
  800cc8:	0f 94 c2             	sete   %dl
  800ccb:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  800cce:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  800cd4:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  800cd7:	39 fb                	cmp    %edi,%ebx
  800cd9:	74 21                	je     800cfc <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  800cdb:	84 d2                	test   %dl,%dl
  800cdd:	74 ca                	je     800ca9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800cdf:	8b 51 58             	mov    0x58(%ecx),%edx
  800ce2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ce6:	89 54 24 08          	mov    %edx,0x8(%esp)
  800cea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cee:	c7 04 24 6c 21 80 00 	movl   $0x80216c,(%esp)
  800cf5:	e8 75 05 00 00       	call   80126f <cprintf>
  800cfa:	eb ad                	jmp    800ca9 <_pipeisclosed+0xe>
}
  800cfc:	83 c4 2c             	add    $0x2c,%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <devpipe_write>:
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
  800d0a:	83 ec 1c             	sub    $0x1c,%esp
  800d0d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800d10:	89 34 24             	mov    %esi,(%esp)
  800d13:	e8 c8 f6 ff ff       	call   8003e0 <fd2data>
	for (i = 0; i < n; i++) {
  800d18:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d1c:	74 61                	je     800d7f <devpipe_write+0x7b>
  800d1e:	89 c3                	mov    %eax,%ebx
  800d20:	bf 00 00 00 00       	mov    $0x0,%edi
  800d25:	eb 4a                	jmp    800d71 <devpipe_write+0x6d>
			if (_pipeisclosed(fd, p))
  800d27:	89 da                	mov    %ebx,%edx
  800d29:	89 f0                	mov    %esi,%eax
  800d2b:	e8 6b ff ff ff       	call   800c9b <_pipeisclosed>
  800d30:	85 c0                	test   %eax,%eax
  800d32:	75 54                	jne    800d88 <devpipe_write+0x84>
			sys_yield();
  800d34:	e8 0f f4 ff ff       	call   800148 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800d39:	8b 43 04             	mov    0x4(%ebx),%eax
  800d3c:	8b 0b                	mov    (%ebx),%ecx
  800d3e:	8d 51 20             	lea    0x20(%ecx),%edx
  800d41:	39 d0                	cmp    %edx,%eax
  800d43:	73 e2                	jae    800d27 <devpipe_write+0x23>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d48:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800d4c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800d4f:	99                   	cltd   
  800d50:	c1 ea 1b             	shr    $0x1b,%edx
  800d53:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  800d56:	83 e1 1f             	and    $0x1f,%ecx
  800d59:	29 d1                	sub    %edx,%ecx
  800d5b:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  800d5f:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  800d63:	83 c0 01             	add    $0x1,%eax
  800d66:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800d69:	83 c7 01             	add    $0x1,%edi
  800d6c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800d6f:	74 13                	je     800d84 <devpipe_write+0x80>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800d71:	8b 43 04             	mov    0x4(%ebx),%eax
  800d74:	8b 0b                	mov    (%ebx),%ecx
  800d76:	8d 51 20             	lea    0x20(%ecx),%edx
  800d79:	39 d0                	cmp    %edx,%eax
  800d7b:	73 aa                	jae    800d27 <devpipe_write+0x23>
  800d7d:	eb c6                	jmp    800d45 <devpipe_write+0x41>
	for (i = 0; i < n; i++) {
  800d7f:	bf 00 00 00 00       	mov    $0x0,%edi
	return i;
  800d84:	89 f8                	mov    %edi,%eax
  800d86:	eb 05                	jmp    800d8d <devpipe_write+0x89>
				return 0;
  800d88:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d8d:	83 c4 1c             	add    $0x1c,%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <devpipe_read>:
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	57                   	push   %edi
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
  800d9b:	83 ec 1c             	sub    $0x1c,%esp
  800d9e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800da1:	89 3c 24             	mov    %edi,(%esp)
  800da4:	e8 37 f6 ff ff       	call   8003e0 <fd2data>
	for (i = 0; i < n; i++) {
  800da9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dad:	74 54                	je     800e03 <devpipe_read+0x6e>
  800daf:	89 c3                	mov    %eax,%ebx
  800db1:	be 00 00 00 00       	mov    $0x0,%esi
  800db6:	eb 3e                	jmp    800df6 <devpipe_read+0x61>
				return i;
  800db8:	89 f0                	mov    %esi,%eax
  800dba:	eb 55                	jmp    800e11 <devpipe_read+0x7c>
			if (_pipeisclosed(fd, p))
  800dbc:	89 da                	mov    %ebx,%edx
  800dbe:	89 f8                	mov    %edi,%eax
  800dc0:	e8 d6 fe ff ff       	call   800c9b <_pipeisclosed>
  800dc5:	85 c0                	test   %eax,%eax
  800dc7:	75 43                	jne    800e0c <devpipe_read+0x77>
			sys_yield();
  800dc9:	e8 7a f3 ff ff       	call   800148 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800dce:	8b 03                	mov    (%ebx),%eax
  800dd0:	3b 43 04             	cmp    0x4(%ebx),%eax
  800dd3:	74 e7                	je     800dbc <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800dd5:	99                   	cltd   
  800dd6:	c1 ea 1b             	shr    $0x1b,%edx
  800dd9:	01 d0                	add    %edx,%eax
  800ddb:	83 e0 1f             	and    $0x1f,%eax
  800dde:	29 d0                	sub    %edx,%eax
  800de0:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800de5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de8:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800deb:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800dee:	83 c6 01             	add    $0x1,%esi
  800df1:	3b 75 10             	cmp    0x10(%ebp),%esi
  800df4:	74 12                	je     800e08 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
  800df6:	8b 03                	mov    (%ebx),%eax
  800df8:	3b 43 04             	cmp    0x4(%ebx),%eax
  800dfb:	75 d8                	jne    800dd5 <devpipe_read+0x40>
			if (i > 0)
  800dfd:	85 f6                	test   %esi,%esi
  800dff:	75 b7                	jne    800db8 <devpipe_read+0x23>
  800e01:	eb b9                	jmp    800dbc <devpipe_read+0x27>
	for (i = 0; i < n; i++) {
  800e03:	be 00 00 00 00       	mov    $0x0,%esi
	return i;
  800e08:	89 f0                	mov    %esi,%eax
  800e0a:	eb 05                	jmp    800e11 <devpipe_read+0x7c>
				return 0;
  800e0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e11:	83 c4 1c             	add    $0x1c,%esp
  800e14:	5b                   	pop    %ebx
  800e15:	5e                   	pop    %esi
  800e16:	5f                   	pop    %edi
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <pipe>:
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	56                   	push   %esi
  800e1d:	53                   	push   %ebx
  800e1e:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800e21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e24:	89 04 24             	mov    %eax,(%esp)
  800e27:	e8 cb f5 ff ff       	call   8003f7 <fd_alloc>
  800e2c:	89 c2                	mov    %eax,%edx
  800e2e:	85 d2                	test   %edx,%edx
  800e30:	0f 88 4d 01 00 00    	js     800f83 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e36:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e3d:	00 
  800e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e41:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e4c:	e8 16 f3 ff ff       	call   800167 <sys_page_alloc>
  800e51:	89 c2                	mov    %eax,%edx
  800e53:	85 d2                	test   %edx,%edx
  800e55:	0f 88 28 01 00 00    	js     800f83 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  800e5b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e5e:	89 04 24             	mov    %eax,(%esp)
  800e61:	e8 91 f5 ff ff       	call   8003f7 <fd_alloc>
  800e66:	89 c3                	mov    %eax,%ebx
  800e68:	85 c0                	test   %eax,%eax
  800e6a:	0f 88 fe 00 00 00    	js     800f6e <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e70:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e77:	00 
  800e78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e86:	e8 dc f2 ff ff       	call   800167 <sys_page_alloc>
  800e8b:	89 c3                	mov    %eax,%ebx
  800e8d:	85 c0                	test   %eax,%eax
  800e8f:	0f 88 d9 00 00 00    	js     800f6e <pipe+0x155>
	va = fd2data(fd0);
  800e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e98:	89 04 24             	mov    %eax,(%esp)
  800e9b:	e8 40 f5 ff ff       	call   8003e0 <fd2data>
  800ea0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ea2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800ea9:	00 
  800eaa:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eb5:	e8 ad f2 ff ff       	call   800167 <sys_page_alloc>
  800eba:	89 c3                	mov    %eax,%ebx
  800ebc:	85 c0                	test   %eax,%eax
  800ebe:	0f 88 97 00 00 00    	js     800f5b <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ec4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ec7:	89 04 24             	mov    %eax,(%esp)
  800eca:	e8 11 f5 ff ff       	call   8003e0 <fd2data>
  800ecf:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800ed6:	00 
  800ed7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800edb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ee2:	00 
  800ee3:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ee7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eee:	e8 c8 f2 ff ff       	call   8001bb <sys_page_map>
  800ef3:	89 c3                	mov    %eax,%ebx
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	78 52                	js     800f4b <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  800ef9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f02:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f07:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800f0e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f14:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f17:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800f19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f1c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f26:	89 04 24             	mov    %eax,(%esp)
  800f29:	e8 a2 f4 ff ff       	call   8003d0 <fd2num>
  800f2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f31:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800f33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f36:	89 04 24             	mov    %eax,(%esp)
  800f39:	e8 92 f4 ff ff       	call   8003d0 <fd2num>
  800f3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f41:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800f44:	b8 00 00 00 00       	mov    $0x0,%eax
  800f49:	eb 38                	jmp    800f83 <pipe+0x16a>
	sys_page_unmap(0, va);
  800f4b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f4f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f56:	e8 b3 f2 ff ff       	call   80020e <sys_page_unmap>
	sys_page_unmap(0, fd1);
  800f5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f62:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f69:	e8 a0 f2 ff ff       	call   80020e <sys_page_unmap>
	sys_page_unmap(0, fd0);
  800f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f71:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f75:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f7c:	e8 8d f2 ff ff       	call   80020e <sys_page_unmap>
  800f81:	89 d8                	mov    %ebx,%eax
}
  800f83:	83 c4 30             	add    $0x30,%esp
  800f86:	5b                   	pop    %ebx
  800f87:	5e                   	pop    %esi
  800f88:	5d                   	pop    %ebp
  800f89:	c3                   	ret    

00800f8a <pipeisclosed>:
{
  800f8a:	55                   	push   %ebp
  800f8b:	89 e5                	mov    %esp,%ebp
  800f8d:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f93:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f97:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9a:	89 04 24             	mov    %eax,(%esp)
  800f9d:	e8 c9 f4 ff ff       	call   80046b <fd_lookup>
  800fa2:	89 c2                	mov    %eax,%edx
  800fa4:	85 d2                	test   %edx,%edx
  800fa6:	78 15                	js     800fbd <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  800fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fab:	89 04 24             	mov    %eax,(%esp)
  800fae:	e8 2d f4 ff ff       	call   8003e0 <fd2data>
	return _pipeisclosed(fd, p);
  800fb3:	89 c2                	mov    %eax,%edx
  800fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb8:	e8 de fc ff ff       	call   800c9b <_pipeisclosed>
}
  800fbd:	c9                   	leave  
  800fbe:	c3                   	ret    
  800fbf:	90                   	nop

00800fc0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800fc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800fd0:	c7 44 24 04 84 21 80 	movl   $0x802184,0x4(%esp)
  800fd7:	00 
  800fd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fdb:	89 04 24             	mov    %eax,(%esp)
  800fde:	e8 e8 08 00 00       	call   8018cb <strcpy>
	return 0;
}
  800fe3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe8:	c9                   	leave  
  800fe9:	c3                   	ret    

00800fea <devcons_write>:
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	57                   	push   %edi
  800fee:	56                   	push   %esi
  800fef:	53                   	push   %ebx
  800ff0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ff6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ffa:	74 4a                	je     801046 <devcons_write+0x5c>
  800ffc:	b8 00 00 00 00       	mov    $0x0,%eax
  801001:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801006:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
		m = n - tot;
  80100c:	8b 75 10             	mov    0x10(%ebp),%esi
  80100f:	29 c6                	sub    %eax,%esi
		if (m > sizeof(buf) - 1)
  801011:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  801014:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801019:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80101c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801020:	03 45 0c             	add    0xc(%ebp),%eax
  801023:	89 44 24 04          	mov    %eax,0x4(%esp)
  801027:	89 3c 24             	mov    %edi,(%esp)
  80102a:	e8 97 0a 00 00       	call   801ac6 <memmove>
		sys_cputs(buf, m);
  80102f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801033:	89 3c 24             	mov    %edi,(%esp)
  801036:	e8 5f f0 ff ff       	call   80009a <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80103b:	01 f3                	add    %esi,%ebx
  80103d:	89 d8                	mov    %ebx,%eax
  80103f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801042:	72 c8                	jb     80100c <devcons_write+0x22>
  801044:	eb 05                	jmp    80104b <devcons_write+0x61>
  801046:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  80104b:	89 d8                	mov    %ebx,%eax
  80104d:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801053:	5b                   	pop    %ebx
  801054:	5e                   	pop    %esi
  801055:	5f                   	pop    %edi
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    

00801058 <devcons_read>:
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	83 ec 08             	sub    $0x8,%esp
		return 0;
  80105e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801063:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801067:	75 07                	jne    801070 <devcons_read+0x18>
  801069:	eb 28                	jmp    801093 <devcons_read+0x3b>
		sys_yield();
  80106b:	e8 d8 f0 ff ff       	call   800148 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801070:	e8 43 f0 ff ff       	call   8000b8 <sys_cgetc>
  801075:	85 c0                	test   %eax,%eax
  801077:	74 f2                	je     80106b <devcons_read+0x13>
	if (c < 0)
  801079:	85 c0                	test   %eax,%eax
  80107b:	78 16                	js     801093 <devcons_read+0x3b>
	if (c == 0x04)	// ctl-d is eof
  80107d:	83 f8 04             	cmp    $0x4,%eax
  801080:	74 0c                	je     80108e <devcons_read+0x36>
	*(char*)vbuf = c;
  801082:	8b 55 0c             	mov    0xc(%ebp),%edx
  801085:	88 02                	mov    %al,(%edx)
	return 1;
  801087:	b8 01 00 00 00       	mov    $0x1,%eax
  80108c:	eb 05                	jmp    801093 <devcons_read+0x3b>
		return 0;
  80108e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801093:	c9                   	leave  
  801094:	c3                   	ret    

00801095 <cputchar>:
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80109b:	8b 45 08             	mov    0x8(%ebp),%eax
  80109e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8010a1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010a8:	00 
  8010a9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010ac:	89 04 24             	mov    %eax,(%esp)
  8010af:	e8 e6 ef ff ff       	call   80009a <sys_cputs>
}
  8010b4:	c9                   	leave  
  8010b5:	c3                   	ret    

008010b6 <getchar>:
{
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  8010bc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8010c3:	00 
  8010c4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010d2:	e8 3f f6 ff ff       	call   800716 <read>
	if (r < 0)
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	78 0f                	js     8010ea <getchar+0x34>
	if (r < 1)
  8010db:	85 c0                	test   %eax,%eax
  8010dd:	7e 06                	jle    8010e5 <getchar+0x2f>
	return c;
  8010df:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8010e3:	eb 05                	jmp    8010ea <getchar+0x34>
		return -E_EOF;
  8010e5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  8010ea:	c9                   	leave  
  8010eb:	c3                   	ret    

008010ec <iscons>:
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fc:	89 04 24             	mov    %eax,(%esp)
  8010ff:	e8 67 f3 ff ff       	call   80046b <fd_lookup>
  801104:	85 c0                	test   %eax,%eax
  801106:	78 11                	js     801119 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  801108:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80110b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801111:	39 10                	cmp    %edx,(%eax)
  801113:	0f 94 c0             	sete   %al
  801116:	0f b6 c0             	movzbl %al,%eax
}
  801119:	c9                   	leave  
  80111a:	c3                   	ret    

0080111b <opencons>:
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801121:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801124:	89 04 24             	mov    %eax,(%esp)
  801127:	e8 cb f2 ff ff       	call   8003f7 <fd_alloc>
		return r;
  80112c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  80112e:	85 c0                	test   %eax,%eax
  801130:	78 40                	js     801172 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801132:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801139:	00 
  80113a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80113d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801141:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801148:	e8 1a f0 ff ff       	call   800167 <sys_page_alloc>
		return r;
  80114d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80114f:	85 c0                	test   %eax,%eax
  801151:	78 1f                	js     801172 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  801153:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801159:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80115e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801161:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801168:	89 04 24             	mov    %eax,(%esp)
  80116b:	e8 60 f2 ff ff       	call   8003d0 <fd2num>
  801170:	89 c2                	mov    %eax,%edx
}
  801172:	89 d0                	mov    %edx,%eax
  801174:	c9                   	leave  
  801175:	c3                   	ret    

00801176 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
  801179:	56                   	push   %esi
  80117a:	53                   	push   %ebx
  80117b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80117e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801181:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801187:	e8 9d ef ff ff       	call   800129 <sys_getenvid>
  80118c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80118f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801193:	8b 55 08             	mov    0x8(%ebp),%edx
  801196:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80119a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80119e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a2:	c7 04 24 90 21 80 00 	movl   $0x802190,(%esp)
  8011a9:	e8 c1 00 00 00       	call   80126f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8011b5:	89 04 24             	mov    %eax,(%esp)
  8011b8:	e8 51 00 00 00       	call   80120e <vcprintf>
	cprintf("\n");
  8011bd:	c7 04 24 7d 21 80 00 	movl   $0x80217d,(%esp)
  8011c4:	e8 a6 00 00 00       	call   80126f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011c9:	cc                   	int3   
  8011ca:	eb fd                	jmp    8011c9 <_panic+0x53>

008011cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	53                   	push   %ebx
  8011d0:	83 ec 14             	sub    $0x14,%esp
  8011d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8011d6:	8b 13                	mov    (%ebx),%edx
  8011d8:	8d 42 01             	lea    0x1(%edx),%eax
  8011db:	89 03                	mov    %eax,(%ebx)
  8011dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8011e4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8011e9:	75 19                	jne    801204 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8011eb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8011f2:	00 
  8011f3:	8d 43 08             	lea    0x8(%ebx),%eax
  8011f6:	89 04 24             	mov    %eax,(%esp)
  8011f9:	e8 9c ee ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  8011fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801204:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801208:	83 c4 14             	add    $0x14,%esp
  80120b:	5b                   	pop    %ebx
  80120c:	5d                   	pop    %ebp
  80120d:	c3                   	ret    

0080120e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801217:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80121e:	00 00 00 
	b.cnt = 0;
  801221:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801228:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80122b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80122e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801232:	8b 45 08             	mov    0x8(%ebp),%eax
  801235:	89 44 24 08          	mov    %eax,0x8(%esp)
  801239:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80123f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801243:	c7 04 24 cc 11 80 00 	movl   $0x8011cc,(%esp)
  80124a:	e8 b5 01 00 00       	call   801404 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80124f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801255:	89 44 24 04          	mov    %eax,0x4(%esp)
  801259:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80125f:	89 04 24             	mov    %eax,(%esp)
  801262:	e8 33 ee ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  801267:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80126d:	c9                   	leave  
  80126e:	c3                   	ret    

0080126f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801275:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801278:	89 44 24 04          	mov    %eax,0x4(%esp)
  80127c:	8b 45 08             	mov    0x8(%ebp),%eax
  80127f:	89 04 24             	mov    %eax,(%esp)
  801282:	e8 87 ff ff ff       	call   80120e <vcprintf>
	va_end(ap);

	return cnt;
}
  801287:	c9                   	leave  
  801288:	c3                   	ret    
  801289:	66 90                	xchg   %ax,%ax
  80128b:	66 90                	xchg   %ax,%ax
  80128d:	66 90                	xchg   %ax,%ax
  80128f:	90                   	nop

00801290 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	57                   	push   %edi
  801294:	56                   	push   %esi
  801295:	53                   	push   %ebx
  801296:	83 ec 3c             	sub    $0x3c,%esp
  801299:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80129c:	89 d7                	mov    %edx,%edi
  80129e:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012a4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012a7:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8012aa:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8012ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8012b5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8012b8:	39 f1                	cmp    %esi,%ecx
  8012ba:	72 14                	jb     8012d0 <printnum+0x40>
  8012bc:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8012bf:	76 0f                	jbe    8012d0 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8012c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c4:	8d 70 ff             	lea    -0x1(%eax),%esi
  8012c7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8012ca:	85 f6                	test   %esi,%esi
  8012cc:	7f 60                	jg     80132e <printnum+0x9e>
  8012ce:	eb 72                	jmp    801342 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8012d0:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8012d3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8012d7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8012da:	8d 51 ff             	lea    -0x1(%ecx),%edx
  8012dd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012e5:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012e9:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8012ed:	89 c3                	mov    %eax,%ebx
  8012ef:	89 d6                	mov    %edx,%esi
  8012f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8012f4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8012f7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012fb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8012ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801302:	89 04 24             	mov    %eax,(%esp)
  801305:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801308:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130c:	e8 cf 0a 00 00       	call   801de0 <__udivdi3>
  801311:	89 d9                	mov    %ebx,%ecx
  801313:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801317:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80131b:	89 04 24             	mov    %eax,(%esp)
  80131e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801322:	89 fa                	mov    %edi,%edx
  801324:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801327:	e8 64 ff ff ff       	call   801290 <printnum>
  80132c:	eb 14                	jmp    801342 <printnum+0xb2>
			putch(padc, putdat);
  80132e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801332:	8b 45 18             	mov    0x18(%ebp),%eax
  801335:	89 04 24             	mov    %eax,(%esp)
  801338:	ff d3                	call   *%ebx
		while (--width > 0)
  80133a:	83 ee 01             	sub    $0x1,%esi
  80133d:	75 ef                	jne    80132e <printnum+0x9e>
  80133f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801342:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801346:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80134a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80134d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801350:	89 44 24 08          	mov    %eax,0x8(%esp)
  801354:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801358:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80135b:	89 04 24             	mov    %eax,(%esp)
  80135e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801361:	89 44 24 04          	mov    %eax,0x4(%esp)
  801365:	e8 a6 0b 00 00       	call   801f10 <__umoddi3>
  80136a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80136e:	0f be 80 b3 21 80 00 	movsbl 0x8021b3(%eax),%eax
  801375:	89 04 24             	mov    %eax,(%esp)
  801378:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80137b:	ff d0                	call   *%eax
}
  80137d:	83 c4 3c             	add    $0x3c,%esp
  801380:	5b                   	pop    %ebx
  801381:	5e                   	pop    %esi
  801382:	5f                   	pop    %edi
  801383:	5d                   	pop    %ebp
  801384:	c3                   	ret    

00801385 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801385:	55                   	push   %ebp
  801386:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801388:	83 fa 01             	cmp    $0x1,%edx
  80138b:	7e 0e                	jle    80139b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80138d:	8b 10                	mov    (%eax),%edx
  80138f:	8d 4a 08             	lea    0x8(%edx),%ecx
  801392:	89 08                	mov    %ecx,(%eax)
  801394:	8b 02                	mov    (%edx),%eax
  801396:	8b 52 04             	mov    0x4(%edx),%edx
  801399:	eb 22                	jmp    8013bd <getuint+0x38>
	else if (lflag)
  80139b:	85 d2                	test   %edx,%edx
  80139d:	74 10                	je     8013af <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80139f:	8b 10                	mov    (%eax),%edx
  8013a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8013a4:	89 08                	mov    %ecx,(%eax)
  8013a6:	8b 02                	mov    (%edx),%eax
  8013a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ad:	eb 0e                	jmp    8013bd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8013af:	8b 10                	mov    (%eax),%edx
  8013b1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8013b4:	89 08                	mov    %ecx,(%eax)
  8013b6:	8b 02                	mov    (%edx),%eax
  8013b8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8013bd:	5d                   	pop    %ebp
  8013be:	c3                   	ret    

008013bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8013bf:	55                   	push   %ebp
  8013c0:	89 e5                	mov    %esp,%ebp
  8013c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8013c5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8013c9:	8b 10                	mov    (%eax),%edx
  8013cb:	3b 50 04             	cmp    0x4(%eax),%edx
  8013ce:	73 0a                	jae    8013da <sprintputch+0x1b>
		*b->buf++ = ch;
  8013d0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8013d3:	89 08                	mov    %ecx,(%eax)
  8013d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d8:	88 02                	mov    %al,(%edx)
}
  8013da:	5d                   	pop    %ebp
  8013db:	c3                   	ret    

008013dc <printfmt>:
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  8013e2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8013e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8013ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fa:	89 04 24             	mov    %eax,(%esp)
  8013fd:	e8 02 00 00 00       	call   801404 <vprintfmt>
}
  801402:	c9                   	leave  
  801403:	c3                   	ret    

00801404 <vprintfmt>:
{
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
  801407:	57                   	push   %edi
  801408:	56                   	push   %esi
  801409:	53                   	push   %ebx
  80140a:	83 ec 3c             	sub    $0x3c,%esp
  80140d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801410:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801413:	eb 18                	jmp    80142d <vprintfmt+0x29>
			if (ch == '\0')
  801415:	85 c0                	test   %eax,%eax
  801417:	0f 84 c3 03 00 00    	je     8017e0 <vprintfmt+0x3dc>
			putch(ch, putdat);
  80141d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801421:	89 04 24             	mov    %eax,(%esp)
  801424:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801427:	89 f3                	mov    %esi,%ebx
  801429:	eb 02                	jmp    80142d <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
  80142b:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80142d:	8d 73 01             	lea    0x1(%ebx),%esi
  801430:	0f b6 03             	movzbl (%ebx),%eax
  801433:	83 f8 25             	cmp    $0x25,%eax
  801436:	75 dd                	jne    801415 <vprintfmt+0x11>
  801438:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80143c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801443:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80144a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801451:	ba 00 00 00 00       	mov    $0x0,%edx
  801456:	eb 1d                	jmp    801475 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  801458:	89 de                	mov    %ebx,%esi
			padc = '-';
  80145a:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80145e:	eb 15                	jmp    801475 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  801460:	89 de                	mov    %ebx,%esi
			padc = '0';
  801462:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  801466:	eb 0d                	jmp    801475 <vprintfmt+0x71>
				width = precision, precision = -1;
  801468:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80146b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80146e:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801475:	8d 5e 01             	lea    0x1(%esi),%ebx
  801478:	0f b6 06             	movzbl (%esi),%eax
  80147b:	0f b6 c8             	movzbl %al,%ecx
  80147e:	83 e8 23             	sub    $0x23,%eax
  801481:	3c 55                	cmp    $0x55,%al
  801483:	0f 87 2f 03 00 00    	ja     8017b8 <vprintfmt+0x3b4>
  801489:	0f b6 c0             	movzbl %al,%eax
  80148c:	ff 24 85 00 23 80 00 	jmp    *0x802300(,%eax,4)
				precision = precision * 10 + ch - '0';
  801493:	8d 41 d0             	lea    -0x30(%ecx),%eax
  801496:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
  801499:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80149d:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8014a0:	83 f9 09             	cmp    $0x9,%ecx
  8014a3:	77 50                	ja     8014f5 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
  8014a5:	89 de                	mov    %ebx,%esi
  8014a7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
  8014aa:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8014ad:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8014b0:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8014b4:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8014b7:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8014ba:	83 fb 09             	cmp    $0x9,%ebx
  8014bd:	76 eb                	jbe    8014aa <vprintfmt+0xa6>
  8014bf:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8014c2:	eb 33                	jmp    8014f7 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
  8014c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c7:	8d 48 04             	lea    0x4(%eax),%ecx
  8014ca:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8014cd:	8b 00                	mov    (%eax),%eax
  8014cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8014d2:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8014d4:	eb 21                	jmp    8014f7 <vprintfmt+0xf3>
  8014d6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8014d9:	85 c9                	test   %ecx,%ecx
  8014db:	b8 00 00 00 00       	mov    $0x0,%eax
  8014e0:	0f 49 c1             	cmovns %ecx,%eax
  8014e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8014e6:	89 de                	mov    %ebx,%esi
  8014e8:	eb 8b                	jmp    801475 <vprintfmt+0x71>
  8014ea:	89 de                	mov    %ebx,%esi
			altflag = 1;
  8014ec:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8014f3:	eb 80                	jmp    801475 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  8014f5:	89 de                	mov    %ebx,%esi
			if (width < 0)
  8014f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8014fb:	0f 89 74 ff ff ff    	jns    801475 <vprintfmt+0x71>
  801501:	e9 62 ff ff ff       	jmp    801468 <vprintfmt+0x64>
			lflag++;
  801506:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  801509:	89 de                	mov    %ebx,%esi
			goto reswitch;
  80150b:	e9 65 ff ff ff       	jmp    801475 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
  801510:	8b 45 14             	mov    0x14(%ebp),%eax
  801513:	8d 50 04             	lea    0x4(%eax),%edx
  801516:	89 55 14             	mov    %edx,0x14(%ebp)
  801519:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80151d:	8b 00                	mov    (%eax),%eax
  80151f:	89 04 24             	mov    %eax,(%esp)
  801522:	ff 55 08             	call   *0x8(%ebp)
			break;
  801525:	e9 03 ff ff ff       	jmp    80142d <vprintfmt+0x29>
			err = va_arg(ap, int);
  80152a:	8b 45 14             	mov    0x14(%ebp),%eax
  80152d:	8d 50 04             	lea    0x4(%eax),%edx
  801530:	89 55 14             	mov    %edx,0x14(%ebp)
  801533:	8b 00                	mov    (%eax),%eax
  801535:	99                   	cltd   
  801536:	31 d0                	xor    %edx,%eax
  801538:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80153a:	83 f8 0f             	cmp    $0xf,%eax
  80153d:	7f 0b                	jg     80154a <vprintfmt+0x146>
  80153f:	8b 14 85 60 24 80 00 	mov    0x802460(,%eax,4),%edx
  801546:	85 d2                	test   %edx,%edx
  801548:	75 20                	jne    80156a <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  80154a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80154e:	c7 44 24 08 cb 21 80 	movl   $0x8021cb,0x8(%esp)
  801555:	00 
  801556:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80155a:	8b 45 08             	mov    0x8(%ebp),%eax
  80155d:	89 04 24             	mov    %eax,(%esp)
  801560:	e8 77 fe ff ff       	call   8013dc <printfmt>
  801565:	e9 c3 fe ff ff       	jmp    80142d <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  80156a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80156e:	c7 44 24 08 4b 21 80 	movl   $0x80214b,0x8(%esp)
  801575:	00 
  801576:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80157a:	8b 45 08             	mov    0x8(%ebp),%eax
  80157d:	89 04 24             	mov    %eax,(%esp)
  801580:	e8 57 fe ff ff       	call   8013dc <printfmt>
  801585:	e9 a3 fe ff ff       	jmp    80142d <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
  80158a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80158d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
  801590:	8b 45 14             	mov    0x14(%ebp),%eax
  801593:	8d 50 04             	lea    0x4(%eax),%edx
  801596:	89 55 14             	mov    %edx,0x14(%ebp)
  801599:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80159b:	85 c0                	test   %eax,%eax
  80159d:	ba c4 21 80 00       	mov    $0x8021c4,%edx
  8015a2:	0f 45 d0             	cmovne %eax,%edx
  8015a5:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8015a8:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8015ac:	74 04                	je     8015b2 <vprintfmt+0x1ae>
  8015ae:	85 f6                	test   %esi,%esi
  8015b0:	7f 19                	jg     8015cb <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8015b2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8015b5:	8d 70 01             	lea    0x1(%eax),%esi
  8015b8:	0f b6 10             	movzbl (%eax),%edx
  8015bb:	0f be c2             	movsbl %dl,%eax
  8015be:	85 c0                	test   %eax,%eax
  8015c0:	0f 85 95 00 00 00    	jne    80165b <vprintfmt+0x257>
  8015c6:	e9 85 00 00 00       	jmp    801650 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8015cb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015cf:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8015d2:	89 04 24             	mov    %eax,(%esp)
  8015d5:	e8 b8 02 00 00       	call   801892 <strnlen>
  8015da:	29 c6                	sub    %eax,%esi
  8015dc:	89 f0                	mov    %esi,%eax
  8015de:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8015e1:	85 f6                	test   %esi,%esi
  8015e3:	7e cd                	jle    8015b2 <vprintfmt+0x1ae>
					putch(padc, putdat);
  8015e5:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8015e9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8015ec:	89 c3                	mov    %eax,%ebx
  8015ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8015f2:	89 34 24             	mov    %esi,(%esp)
  8015f5:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8015f8:	83 eb 01             	sub    $0x1,%ebx
  8015fb:	75 f1                	jne    8015ee <vprintfmt+0x1ea>
  8015fd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801600:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801603:	eb ad                	jmp    8015b2 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
  801605:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801609:	74 1e                	je     801629 <vprintfmt+0x225>
  80160b:	0f be d2             	movsbl %dl,%edx
  80160e:	83 ea 20             	sub    $0x20,%edx
  801611:	83 fa 5e             	cmp    $0x5e,%edx
  801614:	76 13                	jbe    801629 <vprintfmt+0x225>
					putch('?', putdat);
  801616:	8b 45 0c             	mov    0xc(%ebp),%eax
  801619:	89 44 24 04          	mov    %eax,0x4(%esp)
  80161d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801624:	ff 55 08             	call   *0x8(%ebp)
  801627:	eb 0d                	jmp    801636 <vprintfmt+0x232>
					putch(ch, putdat);
  801629:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80162c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801630:	89 04 24             	mov    %eax,(%esp)
  801633:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801636:	83 ef 01             	sub    $0x1,%edi
  801639:	83 c6 01             	add    $0x1,%esi
  80163c:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  801640:	0f be c2             	movsbl %dl,%eax
  801643:	85 c0                	test   %eax,%eax
  801645:	75 20                	jne    801667 <vprintfmt+0x263>
  801647:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80164a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80164d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
  801650:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801654:	7f 25                	jg     80167b <vprintfmt+0x277>
  801656:	e9 d2 fd ff ff       	jmp    80142d <vprintfmt+0x29>
  80165b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80165e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801661:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801664:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801667:	85 db                	test   %ebx,%ebx
  801669:	78 9a                	js     801605 <vprintfmt+0x201>
  80166b:	83 eb 01             	sub    $0x1,%ebx
  80166e:	79 95                	jns    801605 <vprintfmt+0x201>
  801670:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  801673:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801676:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801679:	eb d5                	jmp    801650 <vprintfmt+0x24c>
  80167b:	8b 75 08             	mov    0x8(%ebp),%esi
  80167e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801681:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
  801684:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801688:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80168f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801691:	83 eb 01             	sub    $0x1,%ebx
  801694:	75 ee                	jne    801684 <vprintfmt+0x280>
  801696:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801699:	e9 8f fd ff ff       	jmp    80142d <vprintfmt+0x29>
	if (lflag >= 2)
  80169e:	83 fa 01             	cmp    $0x1,%edx
  8016a1:	7e 16                	jle    8016b9 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
  8016a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8016a6:	8d 50 08             	lea    0x8(%eax),%edx
  8016a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8016ac:	8b 50 04             	mov    0x4(%eax),%edx
  8016af:	8b 00                	mov    (%eax),%eax
  8016b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016b4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8016b7:	eb 32                	jmp    8016eb <vprintfmt+0x2e7>
	else if (lflag)
  8016b9:	85 d2                	test   %edx,%edx
  8016bb:	74 18                	je     8016d5 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8016bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c0:	8d 50 04             	lea    0x4(%eax),%edx
  8016c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8016c6:	8b 30                	mov    (%eax),%esi
  8016c8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8016cb:	89 f0                	mov    %esi,%eax
  8016cd:	c1 f8 1f             	sar    $0x1f,%eax
  8016d0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8016d3:	eb 16                	jmp    8016eb <vprintfmt+0x2e7>
		return va_arg(*ap, int);
  8016d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8016d8:	8d 50 04             	lea    0x4(%eax),%edx
  8016db:	89 55 14             	mov    %edx,0x14(%ebp)
  8016de:	8b 30                	mov    (%eax),%esi
  8016e0:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8016e3:	89 f0                	mov    %esi,%eax
  8016e5:	c1 f8 1f             	sar    $0x1f,%eax
  8016e8:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
  8016eb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8016ee:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
  8016f1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  8016f6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8016fa:	0f 89 80 00 00 00    	jns    801780 <vprintfmt+0x37c>
				putch('-', putdat);
  801700:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801704:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80170b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80170e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801711:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801714:	f7 d8                	neg    %eax
  801716:	83 d2 00             	adc    $0x0,%edx
  801719:	f7 da                	neg    %edx
			base = 10;
  80171b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801720:	eb 5e                	jmp    801780 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  801722:	8d 45 14             	lea    0x14(%ebp),%eax
  801725:	e8 5b fc ff ff       	call   801385 <getuint>
			base = 10;
  80172a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80172f:	eb 4f                	jmp    801780 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  801731:	8d 45 14             	lea    0x14(%ebp),%eax
  801734:	e8 4c fc ff ff       	call   801385 <getuint>
			base = 8;
  801739:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80173e:	eb 40                	jmp    801780 <vprintfmt+0x37c>
			putch('0', putdat);
  801740:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801744:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80174b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80174e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801752:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801759:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  80175c:	8b 45 14             	mov    0x14(%ebp),%eax
  80175f:	8d 50 04             	lea    0x4(%eax),%edx
  801762:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  801765:	8b 00                	mov    (%eax),%eax
  801767:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  80176c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801771:	eb 0d                	jmp    801780 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  801773:	8d 45 14             	lea    0x14(%ebp),%eax
  801776:	e8 0a fc ff ff       	call   801385 <getuint>
			base = 16;
  80177b:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  801780:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  801784:	89 74 24 10          	mov    %esi,0x10(%esp)
  801788:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80178b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80178f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801793:	89 04 24             	mov    %eax,(%esp)
  801796:	89 54 24 04          	mov    %edx,0x4(%esp)
  80179a:	89 fa                	mov    %edi,%edx
  80179c:	8b 45 08             	mov    0x8(%ebp),%eax
  80179f:	e8 ec fa ff ff       	call   801290 <printnum>
			break;
  8017a4:	e9 84 fc ff ff       	jmp    80142d <vprintfmt+0x29>
			putch(ch, putdat);
  8017a9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017ad:	89 0c 24             	mov    %ecx,(%esp)
  8017b0:	ff 55 08             	call   *0x8(%ebp)
			break;
  8017b3:	e9 75 fc ff ff       	jmp    80142d <vprintfmt+0x29>
			putch('%', putdat);
  8017b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017bc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8017c3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8017c6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8017ca:	0f 84 5b fc ff ff    	je     80142b <vprintfmt+0x27>
  8017d0:	89 f3                	mov    %esi,%ebx
  8017d2:	83 eb 01             	sub    $0x1,%ebx
  8017d5:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8017d9:	75 f7                	jne    8017d2 <vprintfmt+0x3ce>
  8017db:	e9 4d fc ff ff       	jmp    80142d <vprintfmt+0x29>
}
  8017e0:	83 c4 3c             	add    $0x3c,%esp
  8017e3:	5b                   	pop    %ebx
  8017e4:	5e                   	pop    %esi
  8017e5:	5f                   	pop    %edi
  8017e6:	5d                   	pop    %ebp
  8017e7:	c3                   	ret    

008017e8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
  8017eb:	83 ec 28             	sub    $0x28,%esp
  8017ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8017f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8017f7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8017fb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8017fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801805:	85 c0                	test   %eax,%eax
  801807:	74 30                	je     801839 <vsnprintf+0x51>
  801809:	85 d2                	test   %edx,%edx
  80180b:	7e 2c                	jle    801839 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80180d:	8b 45 14             	mov    0x14(%ebp),%eax
  801810:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801814:	8b 45 10             	mov    0x10(%ebp),%eax
  801817:	89 44 24 08          	mov    %eax,0x8(%esp)
  80181b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80181e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801822:	c7 04 24 bf 13 80 00 	movl   $0x8013bf,(%esp)
  801829:	e8 d6 fb ff ff       	call   801404 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80182e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801831:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801834:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801837:	eb 05                	jmp    80183e <vsnprintf+0x56>
		return -E_INVAL;
  801839:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80183e:	c9                   	leave  
  80183f:	c3                   	ret    

00801840 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801846:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801849:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80184d:	8b 45 10             	mov    0x10(%ebp),%eax
  801850:	89 44 24 08          	mov    %eax,0x8(%esp)
  801854:	8b 45 0c             	mov    0xc(%ebp),%eax
  801857:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185b:	8b 45 08             	mov    0x8(%ebp),%eax
  80185e:	89 04 24             	mov    %eax,(%esp)
  801861:	e8 82 ff ff ff       	call   8017e8 <vsnprintf>
	va_end(ap);

	return rc;
}
  801866:	c9                   	leave  
  801867:	c3                   	ret    
  801868:	66 90                	xchg   %ax,%ax
  80186a:	66 90                	xchg   %ax,%ax
  80186c:	66 90                	xchg   %ax,%ax
  80186e:	66 90                	xchg   %ax,%ax

00801870 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801876:	80 3a 00             	cmpb   $0x0,(%edx)
  801879:	74 10                	je     80188b <strlen+0x1b>
  80187b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801880:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801883:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801887:	75 f7                	jne    801880 <strlen+0x10>
  801889:	eb 05                	jmp    801890 <strlen+0x20>
  80188b:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  801890:	5d                   	pop    %ebp
  801891:	c3                   	ret    

00801892 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	53                   	push   %ebx
  801896:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801899:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80189c:	85 c9                	test   %ecx,%ecx
  80189e:	74 1c                	je     8018bc <strnlen+0x2a>
  8018a0:	80 3b 00             	cmpb   $0x0,(%ebx)
  8018a3:	74 1e                	je     8018c3 <strnlen+0x31>
  8018a5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8018aa:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8018ac:	39 ca                	cmp    %ecx,%edx
  8018ae:	74 18                	je     8018c8 <strnlen+0x36>
  8018b0:	83 c2 01             	add    $0x1,%edx
  8018b3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8018b8:	75 f0                	jne    8018aa <strnlen+0x18>
  8018ba:	eb 0c                	jmp    8018c8 <strnlen+0x36>
  8018bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c1:	eb 05                	jmp    8018c8 <strnlen+0x36>
  8018c3:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  8018c8:	5b                   	pop    %ebx
  8018c9:	5d                   	pop    %ebp
  8018ca:	c3                   	ret    

008018cb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	53                   	push   %ebx
  8018cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8018d5:	89 c2                	mov    %eax,%edx
  8018d7:	83 c2 01             	add    $0x1,%edx
  8018da:	83 c1 01             	add    $0x1,%ecx
  8018dd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8018e1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8018e4:	84 db                	test   %bl,%bl
  8018e6:	75 ef                	jne    8018d7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8018e8:	5b                   	pop    %ebx
  8018e9:	5d                   	pop    %ebp
  8018ea:	c3                   	ret    

008018eb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	53                   	push   %ebx
  8018ef:	83 ec 08             	sub    $0x8,%esp
  8018f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8018f5:	89 1c 24             	mov    %ebx,(%esp)
  8018f8:	e8 73 ff ff ff       	call   801870 <strlen>
	strcpy(dst + len, src);
  8018fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801900:	89 54 24 04          	mov    %edx,0x4(%esp)
  801904:	01 d8                	add    %ebx,%eax
  801906:	89 04 24             	mov    %eax,(%esp)
  801909:	e8 bd ff ff ff       	call   8018cb <strcpy>
	return dst;
}
  80190e:	89 d8                	mov    %ebx,%eax
  801910:	83 c4 08             	add    $0x8,%esp
  801913:	5b                   	pop    %ebx
  801914:	5d                   	pop    %ebp
  801915:	c3                   	ret    

00801916 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	56                   	push   %esi
  80191a:	53                   	push   %ebx
  80191b:	8b 75 08             	mov    0x8(%ebp),%esi
  80191e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801921:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801924:	85 db                	test   %ebx,%ebx
  801926:	74 17                	je     80193f <strncpy+0x29>
  801928:	01 f3                	add    %esi,%ebx
  80192a:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  80192c:	83 c1 01             	add    $0x1,%ecx
  80192f:	0f b6 02             	movzbl (%edx),%eax
  801932:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801935:	80 3a 01             	cmpb   $0x1,(%edx)
  801938:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80193b:	39 d9                	cmp    %ebx,%ecx
  80193d:	75 ed                	jne    80192c <strncpy+0x16>
	}
	return ret;
}
  80193f:	89 f0                	mov    %esi,%eax
  801941:	5b                   	pop    %ebx
  801942:	5e                   	pop    %esi
  801943:	5d                   	pop    %ebp
  801944:	c3                   	ret    

00801945 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801945:	55                   	push   %ebp
  801946:	89 e5                	mov    %esp,%ebp
  801948:	57                   	push   %edi
  801949:	56                   	push   %esi
  80194a:	53                   	push   %ebx
  80194b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80194e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801951:	8b 75 10             	mov    0x10(%ebp),%esi
  801954:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801956:	85 f6                	test   %esi,%esi
  801958:	74 34                	je     80198e <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  80195a:	83 fe 01             	cmp    $0x1,%esi
  80195d:	74 26                	je     801985 <strlcpy+0x40>
  80195f:	0f b6 0b             	movzbl (%ebx),%ecx
  801962:	84 c9                	test   %cl,%cl
  801964:	74 23                	je     801989 <strlcpy+0x44>
  801966:	83 ee 02             	sub    $0x2,%esi
  801969:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
  80196e:	83 c0 01             	add    $0x1,%eax
  801971:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  801974:	39 f2                	cmp    %esi,%edx
  801976:	74 13                	je     80198b <strlcpy+0x46>
  801978:	83 c2 01             	add    $0x1,%edx
  80197b:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80197f:	84 c9                	test   %cl,%cl
  801981:	75 eb                	jne    80196e <strlcpy+0x29>
  801983:	eb 06                	jmp    80198b <strlcpy+0x46>
  801985:	89 f8                	mov    %edi,%eax
  801987:	eb 02                	jmp    80198b <strlcpy+0x46>
  801989:	89 f8                	mov    %edi,%eax
		*dst = '\0';
  80198b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80198e:	29 f8                	sub    %edi,%eax
}
  801990:	5b                   	pop    %ebx
  801991:	5e                   	pop    %esi
  801992:	5f                   	pop    %edi
  801993:	5d                   	pop    %ebp
  801994:	c3                   	ret    

00801995 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801995:	55                   	push   %ebp
  801996:	89 e5                	mov    %esp,%ebp
  801998:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80199b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80199e:	0f b6 01             	movzbl (%ecx),%eax
  8019a1:	84 c0                	test   %al,%al
  8019a3:	74 15                	je     8019ba <strcmp+0x25>
  8019a5:	3a 02                	cmp    (%edx),%al
  8019a7:	75 11                	jne    8019ba <strcmp+0x25>
		p++, q++;
  8019a9:	83 c1 01             	add    $0x1,%ecx
  8019ac:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8019af:	0f b6 01             	movzbl (%ecx),%eax
  8019b2:	84 c0                	test   %al,%al
  8019b4:	74 04                	je     8019ba <strcmp+0x25>
  8019b6:	3a 02                	cmp    (%edx),%al
  8019b8:	74 ef                	je     8019a9 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8019ba:	0f b6 c0             	movzbl %al,%eax
  8019bd:	0f b6 12             	movzbl (%edx),%edx
  8019c0:	29 d0                	sub    %edx,%eax
}
  8019c2:	5d                   	pop    %ebp
  8019c3:	c3                   	ret    

008019c4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	56                   	push   %esi
  8019c8:	53                   	push   %ebx
  8019c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8019cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019cf:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8019d2:	85 f6                	test   %esi,%esi
  8019d4:	74 29                	je     8019ff <strncmp+0x3b>
  8019d6:	0f b6 03             	movzbl (%ebx),%eax
  8019d9:	84 c0                	test   %al,%al
  8019db:	74 30                	je     801a0d <strncmp+0x49>
  8019dd:	3a 02                	cmp    (%edx),%al
  8019df:	75 2c                	jne    801a0d <strncmp+0x49>
  8019e1:	8d 43 01             	lea    0x1(%ebx),%eax
  8019e4:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8019e6:	89 c3                	mov    %eax,%ebx
  8019e8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8019eb:	39 f0                	cmp    %esi,%eax
  8019ed:	74 17                	je     801a06 <strncmp+0x42>
  8019ef:	0f b6 08             	movzbl (%eax),%ecx
  8019f2:	84 c9                	test   %cl,%cl
  8019f4:	74 17                	je     801a0d <strncmp+0x49>
  8019f6:	83 c0 01             	add    $0x1,%eax
  8019f9:	3a 0a                	cmp    (%edx),%cl
  8019fb:	74 e9                	je     8019e6 <strncmp+0x22>
  8019fd:	eb 0e                	jmp    801a0d <strncmp+0x49>
	if (n == 0)
		return 0;
  8019ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801a04:	eb 0f                	jmp    801a15 <strncmp+0x51>
  801a06:	b8 00 00 00 00       	mov    $0x0,%eax
  801a0b:	eb 08                	jmp    801a15 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801a0d:	0f b6 03             	movzbl (%ebx),%eax
  801a10:	0f b6 12             	movzbl (%edx),%edx
  801a13:	29 d0                	sub    %edx,%eax
}
  801a15:	5b                   	pop    %ebx
  801a16:	5e                   	pop    %esi
  801a17:	5d                   	pop    %ebp
  801a18:	c3                   	ret    

00801a19 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801a19:	55                   	push   %ebp
  801a1a:	89 e5                	mov    %esp,%ebp
  801a1c:	53                   	push   %ebx
  801a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a20:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  801a23:	0f b6 18             	movzbl (%eax),%ebx
  801a26:	84 db                	test   %bl,%bl
  801a28:	74 1d                	je     801a47 <strchr+0x2e>
  801a2a:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  801a2c:	38 d3                	cmp    %dl,%bl
  801a2e:	75 06                	jne    801a36 <strchr+0x1d>
  801a30:	eb 1a                	jmp    801a4c <strchr+0x33>
  801a32:	38 ca                	cmp    %cl,%dl
  801a34:	74 16                	je     801a4c <strchr+0x33>
	for (; *s; s++)
  801a36:	83 c0 01             	add    $0x1,%eax
  801a39:	0f b6 10             	movzbl (%eax),%edx
  801a3c:	84 d2                	test   %dl,%dl
  801a3e:	75 f2                	jne    801a32 <strchr+0x19>
			return (char *) s;
	return 0;
  801a40:	b8 00 00 00 00       	mov    $0x0,%eax
  801a45:	eb 05                	jmp    801a4c <strchr+0x33>
  801a47:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a4c:	5b                   	pop    %ebx
  801a4d:	5d                   	pop    %ebp
  801a4e:	c3                   	ret    

00801a4f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801a4f:	55                   	push   %ebp
  801a50:	89 e5                	mov    %esp,%ebp
  801a52:	53                   	push   %ebx
  801a53:	8b 45 08             	mov    0x8(%ebp),%eax
  801a56:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  801a59:	0f b6 18             	movzbl (%eax),%ebx
  801a5c:	84 db                	test   %bl,%bl
  801a5e:	74 16                	je     801a76 <strfind+0x27>
  801a60:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  801a62:	38 d3                	cmp    %dl,%bl
  801a64:	75 06                	jne    801a6c <strfind+0x1d>
  801a66:	eb 0e                	jmp    801a76 <strfind+0x27>
  801a68:	38 ca                	cmp    %cl,%dl
  801a6a:	74 0a                	je     801a76 <strfind+0x27>
	for (; *s; s++)
  801a6c:	83 c0 01             	add    $0x1,%eax
  801a6f:	0f b6 10             	movzbl (%eax),%edx
  801a72:	84 d2                	test   %dl,%dl
  801a74:	75 f2                	jne    801a68 <strfind+0x19>
			break;
	return (char *) s;
}
  801a76:	5b                   	pop    %ebx
  801a77:	5d                   	pop    %ebp
  801a78:	c3                   	ret    

00801a79 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	57                   	push   %edi
  801a7d:	56                   	push   %esi
  801a7e:	53                   	push   %ebx
  801a7f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a82:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801a85:	85 c9                	test   %ecx,%ecx
  801a87:	74 36                	je     801abf <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801a89:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801a8f:	75 28                	jne    801ab9 <memset+0x40>
  801a91:	f6 c1 03             	test   $0x3,%cl
  801a94:	75 23                	jne    801ab9 <memset+0x40>
		c &= 0xFF;
  801a96:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801a9a:	89 d3                	mov    %edx,%ebx
  801a9c:	c1 e3 08             	shl    $0x8,%ebx
  801a9f:	89 d6                	mov    %edx,%esi
  801aa1:	c1 e6 18             	shl    $0x18,%esi
  801aa4:	89 d0                	mov    %edx,%eax
  801aa6:	c1 e0 10             	shl    $0x10,%eax
  801aa9:	09 f0                	or     %esi,%eax
  801aab:	09 c2                	or     %eax,%edx
  801aad:	89 d0                	mov    %edx,%eax
  801aaf:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801ab1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801ab4:	fc                   	cld    
  801ab5:	f3 ab                	rep stos %eax,%es:(%edi)
  801ab7:	eb 06                	jmp    801abf <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801ab9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801abc:	fc                   	cld    
  801abd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801abf:	89 f8                	mov    %edi,%eax
  801ac1:	5b                   	pop    %ebx
  801ac2:	5e                   	pop    %esi
  801ac3:	5f                   	pop    %edi
  801ac4:	5d                   	pop    %ebp
  801ac5:	c3                   	ret    

00801ac6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	57                   	push   %edi
  801aca:	56                   	push   %esi
  801acb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ace:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ad1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801ad4:	39 c6                	cmp    %eax,%esi
  801ad6:	73 35                	jae    801b0d <memmove+0x47>
  801ad8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801adb:	39 d0                	cmp    %edx,%eax
  801add:	73 2e                	jae    801b0d <memmove+0x47>
		s += n;
		d += n;
  801adf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801ae2:	89 d6                	mov    %edx,%esi
  801ae4:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ae6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801aec:	75 13                	jne    801b01 <memmove+0x3b>
  801aee:	f6 c1 03             	test   $0x3,%cl
  801af1:	75 0e                	jne    801b01 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801af3:	83 ef 04             	sub    $0x4,%edi
  801af6:	8d 72 fc             	lea    -0x4(%edx),%esi
  801af9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801afc:	fd                   	std    
  801afd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801aff:	eb 09                	jmp    801b0a <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801b01:	83 ef 01             	sub    $0x1,%edi
  801b04:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801b07:	fd                   	std    
  801b08:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801b0a:	fc                   	cld    
  801b0b:	eb 1d                	jmp    801b2a <memmove+0x64>
  801b0d:	89 f2                	mov    %esi,%edx
  801b0f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b11:	f6 c2 03             	test   $0x3,%dl
  801b14:	75 0f                	jne    801b25 <memmove+0x5f>
  801b16:	f6 c1 03             	test   $0x3,%cl
  801b19:	75 0a                	jne    801b25 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801b1b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801b1e:	89 c7                	mov    %eax,%edi
  801b20:	fc                   	cld    
  801b21:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801b23:	eb 05                	jmp    801b2a <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  801b25:	89 c7                	mov    %eax,%edi
  801b27:	fc                   	cld    
  801b28:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801b2a:	5e                   	pop    %esi
  801b2b:	5f                   	pop    %edi
  801b2c:	5d                   	pop    %ebp
  801b2d:	c3                   	ret    

00801b2e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
  801b31:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801b34:	8b 45 10             	mov    0x10(%ebp),%eax
  801b37:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b42:	8b 45 08             	mov    0x8(%ebp),%eax
  801b45:	89 04 24             	mov    %eax,(%esp)
  801b48:	e8 79 ff ff ff       	call   801ac6 <memmove>
}
  801b4d:	c9                   	leave  
  801b4e:	c3                   	ret    

00801b4f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801b4f:	55                   	push   %ebp
  801b50:	89 e5                	mov    %esp,%ebp
  801b52:	57                   	push   %edi
  801b53:	56                   	push   %esi
  801b54:	53                   	push   %ebx
  801b55:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b58:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b5b:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801b5e:	8d 78 ff             	lea    -0x1(%eax),%edi
  801b61:	85 c0                	test   %eax,%eax
  801b63:	74 36                	je     801b9b <memcmp+0x4c>
		if (*s1 != *s2)
  801b65:	0f b6 03             	movzbl (%ebx),%eax
  801b68:	0f b6 0e             	movzbl (%esi),%ecx
  801b6b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b70:	38 c8                	cmp    %cl,%al
  801b72:	74 1c                	je     801b90 <memcmp+0x41>
  801b74:	eb 10                	jmp    801b86 <memcmp+0x37>
  801b76:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  801b7b:	83 c2 01             	add    $0x1,%edx
  801b7e:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  801b82:	38 c8                	cmp    %cl,%al
  801b84:	74 0a                	je     801b90 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  801b86:	0f b6 c0             	movzbl %al,%eax
  801b89:	0f b6 c9             	movzbl %cl,%ecx
  801b8c:	29 c8                	sub    %ecx,%eax
  801b8e:	eb 10                	jmp    801ba0 <memcmp+0x51>
	while (n-- > 0) {
  801b90:	39 fa                	cmp    %edi,%edx
  801b92:	75 e2                	jne    801b76 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
  801b94:	b8 00 00 00 00       	mov    $0x0,%eax
  801b99:	eb 05                	jmp    801ba0 <memcmp+0x51>
  801b9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ba0:	5b                   	pop    %ebx
  801ba1:	5e                   	pop    %esi
  801ba2:	5f                   	pop    %edi
  801ba3:	5d                   	pop    %ebp
  801ba4:	c3                   	ret    

00801ba5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	53                   	push   %ebx
  801ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  801baf:	89 c2                	mov    %eax,%edx
  801bb1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801bb4:	39 d0                	cmp    %edx,%eax
  801bb6:	73 13                	jae    801bcb <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801bb8:	89 d9                	mov    %ebx,%ecx
  801bba:	38 18                	cmp    %bl,(%eax)
  801bbc:	75 06                	jne    801bc4 <memfind+0x1f>
  801bbe:	eb 0b                	jmp    801bcb <memfind+0x26>
  801bc0:	38 08                	cmp    %cl,(%eax)
  801bc2:	74 07                	je     801bcb <memfind+0x26>
	for (; s < ends; s++)
  801bc4:	83 c0 01             	add    $0x1,%eax
  801bc7:	39 d0                	cmp    %edx,%eax
  801bc9:	75 f5                	jne    801bc0 <memfind+0x1b>
			break;
	return (void *) s;
}
  801bcb:	5b                   	pop    %ebx
  801bcc:	5d                   	pop    %ebp
  801bcd:	c3                   	ret    

00801bce <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801bce:	55                   	push   %ebp
  801bcf:	89 e5                	mov    %esp,%ebp
  801bd1:	57                   	push   %edi
  801bd2:	56                   	push   %esi
  801bd3:	53                   	push   %ebx
  801bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  801bd7:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801bda:	0f b6 0a             	movzbl (%edx),%ecx
  801bdd:	80 f9 09             	cmp    $0x9,%cl
  801be0:	74 05                	je     801be7 <strtol+0x19>
  801be2:	80 f9 20             	cmp    $0x20,%cl
  801be5:	75 10                	jne    801bf7 <strtol+0x29>
		s++;
  801be7:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801bea:	0f b6 0a             	movzbl (%edx),%ecx
  801bed:	80 f9 09             	cmp    $0x9,%cl
  801bf0:	74 f5                	je     801be7 <strtol+0x19>
  801bf2:	80 f9 20             	cmp    $0x20,%cl
  801bf5:	74 f0                	je     801be7 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
  801bf7:	80 f9 2b             	cmp    $0x2b,%cl
  801bfa:	75 0a                	jne    801c06 <strtol+0x38>
		s++;
  801bfc:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801bff:	bf 00 00 00 00       	mov    $0x0,%edi
  801c04:	eb 11                	jmp    801c17 <strtol+0x49>
  801c06:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  801c0b:	80 f9 2d             	cmp    $0x2d,%cl
  801c0e:	75 07                	jne    801c17 <strtol+0x49>
		s++, neg = 1;
  801c10:	83 c2 01             	add    $0x1,%edx
  801c13:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801c17:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801c1c:	75 15                	jne    801c33 <strtol+0x65>
  801c1e:	80 3a 30             	cmpb   $0x30,(%edx)
  801c21:	75 10                	jne    801c33 <strtol+0x65>
  801c23:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801c27:	75 0a                	jne    801c33 <strtol+0x65>
		s += 2, base = 16;
  801c29:	83 c2 02             	add    $0x2,%edx
  801c2c:	b8 10 00 00 00       	mov    $0x10,%eax
  801c31:	eb 10                	jmp    801c43 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
  801c33:	85 c0                	test   %eax,%eax
  801c35:	75 0c                	jne    801c43 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801c37:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  801c39:	80 3a 30             	cmpb   $0x30,(%edx)
  801c3c:	75 05                	jne    801c43 <strtol+0x75>
		s++, base = 8;
  801c3e:	83 c2 01             	add    $0x1,%edx
  801c41:	b0 08                	mov    $0x8,%al
		base = 10;
  801c43:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c48:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801c4b:	0f b6 0a             	movzbl (%edx),%ecx
  801c4e:	8d 71 d0             	lea    -0x30(%ecx),%esi
  801c51:	89 f0                	mov    %esi,%eax
  801c53:	3c 09                	cmp    $0x9,%al
  801c55:	77 08                	ja     801c5f <strtol+0x91>
			dig = *s - '0';
  801c57:	0f be c9             	movsbl %cl,%ecx
  801c5a:	83 e9 30             	sub    $0x30,%ecx
  801c5d:	eb 20                	jmp    801c7f <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
  801c5f:	8d 71 9f             	lea    -0x61(%ecx),%esi
  801c62:	89 f0                	mov    %esi,%eax
  801c64:	3c 19                	cmp    $0x19,%al
  801c66:	77 08                	ja     801c70 <strtol+0xa2>
			dig = *s - 'a' + 10;
  801c68:	0f be c9             	movsbl %cl,%ecx
  801c6b:	83 e9 57             	sub    $0x57,%ecx
  801c6e:	eb 0f                	jmp    801c7f <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
  801c70:	8d 71 bf             	lea    -0x41(%ecx),%esi
  801c73:	89 f0                	mov    %esi,%eax
  801c75:	3c 19                	cmp    $0x19,%al
  801c77:	77 16                	ja     801c8f <strtol+0xc1>
			dig = *s - 'A' + 10;
  801c79:	0f be c9             	movsbl %cl,%ecx
  801c7c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801c7f:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  801c82:	7d 0f                	jge    801c93 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801c84:	83 c2 01             	add    $0x1,%edx
  801c87:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801c8b:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801c8d:	eb bc                	jmp    801c4b <strtol+0x7d>
  801c8f:	89 d8                	mov    %ebx,%eax
  801c91:	eb 02                	jmp    801c95 <strtol+0xc7>
  801c93:	89 d8                	mov    %ebx,%eax

	if (endptr)
  801c95:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801c99:	74 05                	je     801ca0 <strtol+0xd2>
		*endptr = (char *) s;
  801c9b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c9e:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  801ca0:	f7 d8                	neg    %eax
  801ca2:	85 ff                	test   %edi,%edi
  801ca4:	0f 44 c3             	cmove  %ebx,%eax
}
  801ca7:	5b                   	pop    %ebx
  801ca8:	5e                   	pop    %esi
  801ca9:	5f                   	pop    %edi
  801caa:	5d                   	pop    %ebp
  801cab:	c3                   	ret    

00801cac <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801cac:	55                   	push   %ebp
  801cad:	89 e5                	mov    %esp,%ebp
  801caf:	56                   	push   %esi
  801cb0:	53                   	push   %ebx
  801cb1:	83 ec 10             	sub    $0x10,%esp
  801cb4:	8b 75 08             	mov    0x8(%ebp),%esi
  801cb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int result = sys_ipc_recv(pg);
  801cba:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cbd:	89 04 24             	mov    %eax,(%esp)
  801cc0:	e8 b8 e6 ff ff       	call   80037d <sys_ipc_recv>
	if(from_env_store)
  801cc5:	85 f6                	test   %esi,%esi
  801cc7:	74 14                	je     801cdd <ipc_recv+0x31>
		*from_env_store = (result<0?0:thisenv->env_ipc_from);
  801cc9:	ba 00 00 00 00       	mov    $0x0,%edx
  801cce:	85 c0                	test   %eax,%eax
  801cd0:	78 09                	js     801cdb <ipc_recv+0x2f>
  801cd2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801cd8:	8b 52 74             	mov    0x74(%edx),%edx
  801cdb:	89 16                	mov    %edx,(%esi)
	if(perm_store)
  801cdd:	85 db                	test   %ebx,%ebx
  801cdf:	74 14                	je     801cf5 <ipc_recv+0x49>
		*perm_store = (result<0?0:thisenv->env_ipc_perm);
  801ce1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce6:	85 c0                	test   %eax,%eax
  801ce8:	78 09                	js     801cf3 <ipc_recv+0x47>
  801cea:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801cf0:	8b 52 78             	mov    0x78(%edx),%edx
  801cf3:	89 13                	mov    %edx,(%ebx)
	if(result < 0)
  801cf5:	85 c0                	test   %eax,%eax
  801cf7:	78 08                	js     801d01 <ipc_recv+0x55>
		return result;
	return thisenv->env_ipc_value;
  801cf9:	a1 04 40 80 00       	mov    0x804004,%eax
  801cfe:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d01:	83 c4 10             	add    $0x10,%esp
  801d04:	5b                   	pop    %ebx
  801d05:	5e                   	pop    %esi
  801d06:	5d                   	pop    %ebp
  801d07:	c3                   	ret    

00801d08 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d08:	55                   	push   %ebp
  801d09:	89 e5                	mov    %esp,%ebp
  801d0b:	57                   	push   %edi
  801d0c:	56                   	push   %esi
  801d0d:	53                   	push   %ebx
  801d0e:	83 ec 1c             	sub    $0x1c,%esp
  801d11:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d14:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	unsigned failed_cnt = 0;
  801d17:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  801d1c:	eb 0c                	jmp    801d2a <ipc_send+0x22>
		failed_cnt++;
  801d1e:	83 c3 01             	add    $0x1,%ebx
		if(!(failed_cnt & 0xff))
  801d21:	84 db                	test   %bl,%bl
  801d23:	75 05                	jne    801d2a <ipc_send+0x22>
			//失败到一定次数后放弃CPU
			sys_yield();
  801d25:	e8 1e e4 ff ff       	call   800148 <sys_yield>
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  801d2a:	8b 45 14             	mov    0x14(%ebp),%eax
  801d2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d31:	8b 45 10             	mov    0x10(%ebp),%eax
  801d34:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d38:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d3c:	89 3c 24             	mov    %edi,(%esp)
  801d3f:	e8 16 e6 ff ff       	call   80035a <sys_ipc_try_send>
  801d44:	85 c0                	test   %eax,%eax
  801d46:	78 d6                	js     801d1e <ipc_send+0x16>
	}
}
  801d48:	83 c4 1c             	add    $0x1c,%esp
  801d4b:	5b                   	pop    %ebx
  801d4c:	5e                   	pop    %esi
  801d4d:	5f                   	pop    %edi
  801d4e:	5d                   	pop    %ebp
  801d4f:	c3                   	ret    

00801d50 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801d56:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801d5b:	39 c8                	cmp    %ecx,%eax
  801d5d:	74 17                	je     801d76 <ipc_find_env+0x26>
	for (i = 0; i < NENV; i++)
  801d5f:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801d64:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d67:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d6d:	8b 52 50             	mov    0x50(%edx),%edx
  801d70:	39 ca                	cmp    %ecx,%edx
  801d72:	75 14                	jne    801d88 <ipc_find_env+0x38>
  801d74:	eb 05                	jmp    801d7b <ipc_find_env+0x2b>
	for (i = 0; i < NENV; i++)
  801d76:	b8 00 00 00 00       	mov    $0x0,%eax
			return envs[i].env_id;
  801d7b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d7e:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801d83:	8b 40 40             	mov    0x40(%eax),%eax
  801d86:	eb 0e                	jmp    801d96 <ipc_find_env+0x46>
	for (i = 0; i < NENV; i++)
  801d88:	83 c0 01             	add    $0x1,%eax
  801d8b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d90:	75 d2                	jne    801d64 <ipc_find_env+0x14>
	return 0;
  801d92:	66 b8 00 00          	mov    $0x0,%ax
}
  801d96:	5d                   	pop    %ebp
  801d97:	c3                   	ret    

00801d98 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
  801d9b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d9e:	89 d0                	mov    %edx,%eax
  801da0:	c1 e8 16             	shr    $0x16,%eax
  801da3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801daa:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801daf:	f6 c1 01             	test   $0x1,%cl
  801db2:	74 1d                	je     801dd1 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801db4:	c1 ea 0c             	shr    $0xc,%edx
  801db7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801dbe:	f6 c2 01             	test   $0x1,%dl
  801dc1:	74 0e                	je     801dd1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801dc3:	c1 ea 0c             	shr    $0xc,%edx
  801dc6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801dcd:	ef 
  801dce:	0f b7 c0             	movzwl %ax,%eax
}
  801dd1:	5d                   	pop    %ebp
  801dd2:	c3                   	ret    
  801dd3:	66 90                	xchg   %ax,%ax
  801dd5:	66 90                	xchg   %ax,%ax
  801dd7:	66 90                	xchg   %ax,%ax
  801dd9:	66 90                	xchg   %ax,%ax
  801ddb:	66 90                	xchg   %ax,%ax
  801ddd:	66 90                	xchg   %ax,%ax
  801ddf:	90                   	nop

00801de0 <__udivdi3>:
  801de0:	55                   	push   %ebp
  801de1:	57                   	push   %edi
  801de2:	56                   	push   %esi
  801de3:	83 ec 0c             	sub    $0xc,%esp
  801de6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801dea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801dee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801df2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801df6:	85 c0                	test   %eax,%eax
  801df8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801dfc:	89 ea                	mov    %ebp,%edx
  801dfe:	89 0c 24             	mov    %ecx,(%esp)
  801e01:	75 2d                	jne    801e30 <__udivdi3+0x50>
  801e03:	39 e9                	cmp    %ebp,%ecx
  801e05:	77 61                	ja     801e68 <__udivdi3+0x88>
  801e07:	85 c9                	test   %ecx,%ecx
  801e09:	89 ce                	mov    %ecx,%esi
  801e0b:	75 0b                	jne    801e18 <__udivdi3+0x38>
  801e0d:	b8 01 00 00 00       	mov    $0x1,%eax
  801e12:	31 d2                	xor    %edx,%edx
  801e14:	f7 f1                	div    %ecx
  801e16:	89 c6                	mov    %eax,%esi
  801e18:	31 d2                	xor    %edx,%edx
  801e1a:	89 e8                	mov    %ebp,%eax
  801e1c:	f7 f6                	div    %esi
  801e1e:	89 c5                	mov    %eax,%ebp
  801e20:	89 f8                	mov    %edi,%eax
  801e22:	f7 f6                	div    %esi
  801e24:	89 ea                	mov    %ebp,%edx
  801e26:	83 c4 0c             	add    $0xc,%esp
  801e29:	5e                   	pop    %esi
  801e2a:	5f                   	pop    %edi
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    
  801e2d:	8d 76 00             	lea    0x0(%esi),%esi
  801e30:	39 e8                	cmp    %ebp,%eax
  801e32:	77 24                	ja     801e58 <__udivdi3+0x78>
  801e34:	0f bd e8             	bsr    %eax,%ebp
  801e37:	83 f5 1f             	xor    $0x1f,%ebp
  801e3a:	75 3c                	jne    801e78 <__udivdi3+0x98>
  801e3c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801e40:	39 34 24             	cmp    %esi,(%esp)
  801e43:	0f 86 9f 00 00 00    	jbe    801ee8 <__udivdi3+0x108>
  801e49:	39 d0                	cmp    %edx,%eax
  801e4b:	0f 82 97 00 00 00    	jb     801ee8 <__udivdi3+0x108>
  801e51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e58:	31 d2                	xor    %edx,%edx
  801e5a:	31 c0                	xor    %eax,%eax
  801e5c:	83 c4 0c             	add    $0xc,%esp
  801e5f:	5e                   	pop    %esi
  801e60:	5f                   	pop    %edi
  801e61:	5d                   	pop    %ebp
  801e62:	c3                   	ret    
  801e63:	90                   	nop
  801e64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e68:	89 f8                	mov    %edi,%eax
  801e6a:	f7 f1                	div    %ecx
  801e6c:	31 d2                	xor    %edx,%edx
  801e6e:	83 c4 0c             	add    $0xc,%esp
  801e71:	5e                   	pop    %esi
  801e72:	5f                   	pop    %edi
  801e73:	5d                   	pop    %ebp
  801e74:	c3                   	ret    
  801e75:	8d 76 00             	lea    0x0(%esi),%esi
  801e78:	89 e9                	mov    %ebp,%ecx
  801e7a:	8b 3c 24             	mov    (%esp),%edi
  801e7d:	d3 e0                	shl    %cl,%eax
  801e7f:	89 c6                	mov    %eax,%esi
  801e81:	b8 20 00 00 00       	mov    $0x20,%eax
  801e86:	29 e8                	sub    %ebp,%eax
  801e88:	89 c1                	mov    %eax,%ecx
  801e8a:	d3 ef                	shr    %cl,%edi
  801e8c:	89 e9                	mov    %ebp,%ecx
  801e8e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801e92:	8b 3c 24             	mov    (%esp),%edi
  801e95:	09 74 24 08          	or     %esi,0x8(%esp)
  801e99:	89 d6                	mov    %edx,%esi
  801e9b:	d3 e7                	shl    %cl,%edi
  801e9d:	89 c1                	mov    %eax,%ecx
  801e9f:	89 3c 24             	mov    %edi,(%esp)
  801ea2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ea6:	d3 ee                	shr    %cl,%esi
  801ea8:	89 e9                	mov    %ebp,%ecx
  801eaa:	d3 e2                	shl    %cl,%edx
  801eac:	89 c1                	mov    %eax,%ecx
  801eae:	d3 ef                	shr    %cl,%edi
  801eb0:	09 d7                	or     %edx,%edi
  801eb2:	89 f2                	mov    %esi,%edx
  801eb4:	89 f8                	mov    %edi,%eax
  801eb6:	f7 74 24 08          	divl   0x8(%esp)
  801eba:	89 d6                	mov    %edx,%esi
  801ebc:	89 c7                	mov    %eax,%edi
  801ebe:	f7 24 24             	mull   (%esp)
  801ec1:	39 d6                	cmp    %edx,%esi
  801ec3:	89 14 24             	mov    %edx,(%esp)
  801ec6:	72 30                	jb     801ef8 <__udivdi3+0x118>
  801ec8:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ecc:	89 e9                	mov    %ebp,%ecx
  801ece:	d3 e2                	shl    %cl,%edx
  801ed0:	39 c2                	cmp    %eax,%edx
  801ed2:	73 05                	jae    801ed9 <__udivdi3+0xf9>
  801ed4:	3b 34 24             	cmp    (%esp),%esi
  801ed7:	74 1f                	je     801ef8 <__udivdi3+0x118>
  801ed9:	89 f8                	mov    %edi,%eax
  801edb:	31 d2                	xor    %edx,%edx
  801edd:	e9 7a ff ff ff       	jmp    801e5c <__udivdi3+0x7c>
  801ee2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ee8:	31 d2                	xor    %edx,%edx
  801eea:	b8 01 00 00 00       	mov    $0x1,%eax
  801eef:	e9 68 ff ff ff       	jmp    801e5c <__udivdi3+0x7c>
  801ef4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ef8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801efb:	31 d2                	xor    %edx,%edx
  801efd:	83 c4 0c             	add    $0xc,%esp
  801f00:	5e                   	pop    %esi
  801f01:	5f                   	pop    %edi
  801f02:	5d                   	pop    %ebp
  801f03:	c3                   	ret    
  801f04:	66 90                	xchg   %ax,%ax
  801f06:	66 90                	xchg   %ax,%ax
  801f08:	66 90                	xchg   %ax,%ax
  801f0a:	66 90                	xchg   %ax,%ax
  801f0c:	66 90                	xchg   %ax,%ax
  801f0e:	66 90                	xchg   %ax,%ax

00801f10 <__umoddi3>:
  801f10:	55                   	push   %ebp
  801f11:	57                   	push   %edi
  801f12:	56                   	push   %esi
  801f13:	83 ec 14             	sub    $0x14,%esp
  801f16:	8b 44 24 28          	mov    0x28(%esp),%eax
  801f1a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801f1e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801f22:	89 c7                	mov    %eax,%edi
  801f24:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f28:	8b 44 24 30          	mov    0x30(%esp),%eax
  801f2c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801f30:	89 34 24             	mov    %esi,(%esp)
  801f33:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f37:	85 c0                	test   %eax,%eax
  801f39:	89 c2                	mov    %eax,%edx
  801f3b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f3f:	75 17                	jne    801f58 <__umoddi3+0x48>
  801f41:	39 fe                	cmp    %edi,%esi
  801f43:	76 4b                	jbe    801f90 <__umoddi3+0x80>
  801f45:	89 c8                	mov    %ecx,%eax
  801f47:	89 fa                	mov    %edi,%edx
  801f49:	f7 f6                	div    %esi
  801f4b:	89 d0                	mov    %edx,%eax
  801f4d:	31 d2                	xor    %edx,%edx
  801f4f:	83 c4 14             	add    $0x14,%esp
  801f52:	5e                   	pop    %esi
  801f53:	5f                   	pop    %edi
  801f54:	5d                   	pop    %ebp
  801f55:	c3                   	ret    
  801f56:	66 90                	xchg   %ax,%ax
  801f58:	39 f8                	cmp    %edi,%eax
  801f5a:	77 54                	ja     801fb0 <__umoddi3+0xa0>
  801f5c:	0f bd e8             	bsr    %eax,%ebp
  801f5f:	83 f5 1f             	xor    $0x1f,%ebp
  801f62:	75 5c                	jne    801fc0 <__umoddi3+0xb0>
  801f64:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801f68:	39 3c 24             	cmp    %edi,(%esp)
  801f6b:	0f 87 e7 00 00 00    	ja     802058 <__umoddi3+0x148>
  801f71:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801f75:	29 f1                	sub    %esi,%ecx
  801f77:	19 c7                	sbb    %eax,%edi
  801f79:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f7d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f81:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f85:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801f89:	83 c4 14             	add    $0x14,%esp
  801f8c:	5e                   	pop    %esi
  801f8d:	5f                   	pop    %edi
  801f8e:	5d                   	pop    %ebp
  801f8f:	c3                   	ret    
  801f90:	85 f6                	test   %esi,%esi
  801f92:	89 f5                	mov    %esi,%ebp
  801f94:	75 0b                	jne    801fa1 <__umoddi3+0x91>
  801f96:	b8 01 00 00 00       	mov    $0x1,%eax
  801f9b:	31 d2                	xor    %edx,%edx
  801f9d:	f7 f6                	div    %esi
  801f9f:	89 c5                	mov    %eax,%ebp
  801fa1:	8b 44 24 04          	mov    0x4(%esp),%eax
  801fa5:	31 d2                	xor    %edx,%edx
  801fa7:	f7 f5                	div    %ebp
  801fa9:	89 c8                	mov    %ecx,%eax
  801fab:	f7 f5                	div    %ebp
  801fad:	eb 9c                	jmp    801f4b <__umoddi3+0x3b>
  801faf:	90                   	nop
  801fb0:	89 c8                	mov    %ecx,%eax
  801fb2:	89 fa                	mov    %edi,%edx
  801fb4:	83 c4 14             	add    $0x14,%esp
  801fb7:	5e                   	pop    %esi
  801fb8:	5f                   	pop    %edi
  801fb9:	5d                   	pop    %ebp
  801fba:	c3                   	ret    
  801fbb:	90                   	nop
  801fbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fc0:	8b 04 24             	mov    (%esp),%eax
  801fc3:	be 20 00 00 00       	mov    $0x20,%esi
  801fc8:	89 e9                	mov    %ebp,%ecx
  801fca:	29 ee                	sub    %ebp,%esi
  801fcc:	d3 e2                	shl    %cl,%edx
  801fce:	89 f1                	mov    %esi,%ecx
  801fd0:	d3 e8                	shr    %cl,%eax
  801fd2:	89 e9                	mov    %ebp,%ecx
  801fd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd8:	8b 04 24             	mov    (%esp),%eax
  801fdb:	09 54 24 04          	or     %edx,0x4(%esp)
  801fdf:	89 fa                	mov    %edi,%edx
  801fe1:	d3 e0                	shl    %cl,%eax
  801fe3:	89 f1                	mov    %esi,%ecx
  801fe5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fe9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801fed:	d3 ea                	shr    %cl,%edx
  801fef:	89 e9                	mov    %ebp,%ecx
  801ff1:	d3 e7                	shl    %cl,%edi
  801ff3:	89 f1                	mov    %esi,%ecx
  801ff5:	d3 e8                	shr    %cl,%eax
  801ff7:	89 e9                	mov    %ebp,%ecx
  801ff9:	09 f8                	or     %edi,%eax
  801ffb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801fff:	f7 74 24 04          	divl   0x4(%esp)
  802003:	d3 e7                	shl    %cl,%edi
  802005:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802009:	89 d7                	mov    %edx,%edi
  80200b:	f7 64 24 08          	mull   0x8(%esp)
  80200f:	39 d7                	cmp    %edx,%edi
  802011:	89 c1                	mov    %eax,%ecx
  802013:	89 14 24             	mov    %edx,(%esp)
  802016:	72 2c                	jb     802044 <__umoddi3+0x134>
  802018:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80201c:	72 22                	jb     802040 <__umoddi3+0x130>
  80201e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802022:	29 c8                	sub    %ecx,%eax
  802024:	19 d7                	sbb    %edx,%edi
  802026:	89 e9                	mov    %ebp,%ecx
  802028:	89 fa                	mov    %edi,%edx
  80202a:	d3 e8                	shr    %cl,%eax
  80202c:	89 f1                	mov    %esi,%ecx
  80202e:	d3 e2                	shl    %cl,%edx
  802030:	89 e9                	mov    %ebp,%ecx
  802032:	d3 ef                	shr    %cl,%edi
  802034:	09 d0                	or     %edx,%eax
  802036:	89 fa                	mov    %edi,%edx
  802038:	83 c4 14             	add    $0x14,%esp
  80203b:	5e                   	pop    %esi
  80203c:	5f                   	pop    %edi
  80203d:	5d                   	pop    %ebp
  80203e:	c3                   	ret    
  80203f:	90                   	nop
  802040:	39 d7                	cmp    %edx,%edi
  802042:	75 da                	jne    80201e <__umoddi3+0x10e>
  802044:	8b 14 24             	mov    (%esp),%edx
  802047:	89 c1                	mov    %eax,%ecx
  802049:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80204d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802051:	eb cb                	jmp    80201e <__umoddi3+0x10e>
  802053:	90                   	nop
  802054:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802058:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80205c:	0f 82 0f ff ff ff    	jb     801f71 <__umoddi3+0x61>
  802062:	e9 1a ff ff ff       	jmp    801f81 <__umoddi3+0x71>
