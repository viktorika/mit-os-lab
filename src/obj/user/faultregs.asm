
obj/user/faultregs.debug：     文件格式 elf32-i386


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
  80002c:	e8 64 05 00 00       	call   800595 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	8b 45 08             	mov    0x8(%ebp),%eax
  800043:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800047:	89 54 24 08          	mov    %edx,0x8(%esp)
  80004b:	c7 44 24 04 b1 26 80 	movl   $0x8026b1,0x4(%esp)
  800052:	00 
  800053:	c7 04 24 80 26 80 00 	movl   $0x802680,(%esp)
  80005a:	e8 90 06 00 00       	call   8006ef <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  80005f:	8b 03                	mov    (%ebx),%eax
  800061:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800065:	8b 06                	mov    (%esi),%eax
  800067:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006b:	c7 44 24 04 90 26 80 	movl   $0x802690,0x4(%esp)
  800072:	00 
  800073:	c7 04 24 94 26 80 00 	movl   $0x802694,(%esp)
  80007a:	e8 70 06 00 00       	call   8006ef <cprintf>
  80007f:	8b 03                	mov    (%ebx),%eax
  800081:	39 06                	cmp    %eax,(%esi)
  800083:	75 13                	jne    800098 <check_regs+0x65>
  800085:	c7 04 24 a4 26 80 00 	movl   $0x8026a4,(%esp)
  80008c:	e8 5e 06 00 00       	call   8006ef <cprintf>
	int mismatch = 0;
  800091:	bf 00 00 00 00       	mov    $0x0,%edi
  800096:	eb 11                	jmp    8000a9 <check_regs+0x76>
	CHECK(edi, regs.reg_edi);
  800098:	c7 04 24 a8 26 80 00 	movl   $0x8026a8,(%esp)
  80009f:	e8 4b 06 00 00       	call   8006ef <cprintf>
  8000a4:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000a9:	8b 43 04             	mov    0x4(%ebx),%eax
  8000ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b0:	8b 46 04             	mov    0x4(%esi),%eax
  8000b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b7:	c7 44 24 04 b2 26 80 	movl   $0x8026b2,0x4(%esp)
  8000be:	00 
  8000bf:	c7 04 24 94 26 80 00 	movl   $0x802694,(%esp)
  8000c6:	e8 24 06 00 00       	call   8006ef <cprintf>
  8000cb:	8b 43 04             	mov    0x4(%ebx),%eax
  8000ce:	39 46 04             	cmp    %eax,0x4(%esi)
  8000d1:	75 0e                	jne    8000e1 <check_regs+0xae>
  8000d3:	c7 04 24 a4 26 80 00 	movl   $0x8026a4,(%esp)
  8000da:	e8 10 06 00 00       	call   8006ef <cprintf>
  8000df:	eb 11                	jmp    8000f2 <check_regs+0xbf>
  8000e1:	c7 04 24 a8 26 80 00 	movl   $0x8026a8,(%esp)
  8000e8:	e8 02 06 00 00       	call   8006ef <cprintf>
  8000ed:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000f2:	8b 43 08             	mov    0x8(%ebx),%eax
  8000f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f9:	8b 46 08             	mov    0x8(%esi),%eax
  8000fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800100:	c7 44 24 04 b6 26 80 	movl   $0x8026b6,0x4(%esp)
  800107:	00 
  800108:	c7 04 24 94 26 80 00 	movl   $0x802694,(%esp)
  80010f:	e8 db 05 00 00       	call   8006ef <cprintf>
  800114:	8b 43 08             	mov    0x8(%ebx),%eax
  800117:	39 46 08             	cmp    %eax,0x8(%esi)
  80011a:	75 0e                	jne    80012a <check_regs+0xf7>
  80011c:	c7 04 24 a4 26 80 00 	movl   $0x8026a4,(%esp)
  800123:	e8 c7 05 00 00       	call   8006ef <cprintf>
  800128:	eb 11                	jmp    80013b <check_regs+0x108>
  80012a:	c7 04 24 a8 26 80 00 	movl   $0x8026a8,(%esp)
  800131:	e8 b9 05 00 00       	call   8006ef <cprintf>
  800136:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80013b:	8b 43 10             	mov    0x10(%ebx),%eax
  80013e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800142:	8b 46 10             	mov    0x10(%esi),%eax
  800145:	89 44 24 08          	mov    %eax,0x8(%esp)
  800149:	c7 44 24 04 ba 26 80 	movl   $0x8026ba,0x4(%esp)
  800150:	00 
  800151:	c7 04 24 94 26 80 00 	movl   $0x802694,(%esp)
  800158:	e8 92 05 00 00       	call   8006ef <cprintf>
  80015d:	8b 43 10             	mov    0x10(%ebx),%eax
  800160:	39 46 10             	cmp    %eax,0x10(%esi)
  800163:	75 0e                	jne    800173 <check_regs+0x140>
  800165:	c7 04 24 a4 26 80 00 	movl   $0x8026a4,(%esp)
  80016c:	e8 7e 05 00 00       	call   8006ef <cprintf>
  800171:	eb 11                	jmp    800184 <check_regs+0x151>
  800173:	c7 04 24 a8 26 80 00 	movl   $0x8026a8,(%esp)
  80017a:	e8 70 05 00 00       	call   8006ef <cprintf>
  80017f:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800184:	8b 43 14             	mov    0x14(%ebx),%eax
  800187:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018b:	8b 46 14             	mov    0x14(%esi),%eax
  80018e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800192:	c7 44 24 04 be 26 80 	movl   $0x8026be,0x4(%esp)
  800199:	00 
  80019a:	c7 04 24 94 26 80 00 	movl   $0x802694,(%esp)
  8001a1:	e8 49 05 00 00       	call   8006ef <cprintf>
  8001a6:	8b 43 14             	mov    0x14(%ebx),%eax
  8001a9:	39 46 14             	cmp    %eax,0x14(%esi)
  8001ac:	75 0e                	jne    8001bc <check_regs+0x189>
  8001ae:	c7 04 24 a4 26 80 00 	movl   $0x8026a4,(%esp)
  8001b5:	e8 35 05 00 00       	call   8006ef <cprintf>
  8001ba:	eb 11                	jmp    8001cd <check_regs+0x19a>
  8001bc:	c7 04 24 a8 26 80 00 	movl   $0x8026a8,(%esp)
  8001c3:	e8 27 05 00 00       	call   8006ef <cprintf>
  8001c8:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001cd:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d4:	8b 46 18             	mov    0x18(%esi),%eax
  8001d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001db:	c7 44 24 04 c2 26 80 	movl   $0x8026c2,0x4(%esp)
  8001e2:	00 
  8001e3:	c7 04 24 94 26 80 00 	movl   $0x802694,(%esp)
  8001ea:	e8 00 05 00 00       	call   8006ef <cprintf>
  8001ef:	8b 43 18             	mov    0x18(%ebx),%eax
  8001f2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001f5:	75 0e                	jne    800205 <check_regs+0x1d2>
  8001f7:	c7 04 24 a4 26 80 00 	movl   $0x8026a4,(%esp)
  8001fe:	e8 ec 04 00 00       	call   8006ef <cprintf>
  800203:	eb 11                	jmp    800216 <check_regs+0x1e3>
  800205:	c7 04 24 a8 26 80 00 	movl   $0x8026a8,(%esp)
  80020c:	e8 de 04 00 00       	call   8006ef <cprintf>
  800211:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021d:	8b 46 1c             	mov    0x1c(%esi),%eax
  800220:	89 44 24 08          	mov    %eax,0x8(%esp)
  800224:	c7 44 24 04 c6 26 80 	movl   $0x8026c6,0x4(%esp)
  80022b:	00 
  80022c:	c7 04 24 94 26 80 00 	movl   $0x802694,(%esp)
  800233:	e8 b7 04 00 00       	call   8006ef <cprintf>
  800238:	8b 43 1c             	mov    0x1c(%ebx),%eax
  80023b:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80023e:	75 0e                	jne    80024e <check_regs+0x21b>
  800240:	c7 04 24 a4 26 80 00 	movl   $0x8026a4,(%esp)
  800247:	e8 a3 04 00 00       	call   8006ef <cprintf>
  80024c:	eb 11                	jmp    80025f <check_regs+0x22c>
  80024e:	c7 04 24 a8 26 80 00 	movl   $0x8026a8,(%esp)
  800255:	e8 95 04 00 00       	call   8006ef <cprintf>
  80025a:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  80025f:	8b 43 20             	mov    0x20(%ebx),%eax
  800262:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800266:	8b 46 20             	mov    0x20(%esi),%eax
  800269:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026d:	c7 44 24 04 ca 26 80 	movl   $0x8026ca,0x4(%esp)
  800274:	00 
  800275:	c7 04 24 94 26 80 00 	movl   $0x802694,(%esp)
  80027c:	e8 6e 04 00 00       	call   8006ef <cprintf>
  800281:	8b 43 20             	mov    0x20(%ebx),%eax
  800284:	39 46 20             	cmp    %eax,0x20(%esi)
  800287:	75 0e                	jne    800297 <check_regs+0x264>
  800289:	c7 04 24 a4 26 80 00 	movl   $0x8026a4,(%esp)
  800290:	e8 5a 04 00 00       	call   8006ef <cprintf>
  800295:	eb 11                	jmp    8002a8 <check_regs+0x275>
  800297:	c7 04 24 a8 26 80 00 	movl   $0x8026a8,(%esp)
  80029e:	e8 4c 04 00 00       	call   8006ef <cprintf>
  8002a3:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002a8:	8b 43 24             	mov    0x24(%ebx),%eax
  8002ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002af:	8b 46 24             	mov    0x24(%esi),%eax
  8002b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b6:	c7 44 24 04 ce 26 80 	movl   $0x8026ce,0x4(%esp)
  8002bd:	00 
  8002be:	c7 04 24 94 26 80 00 	movl   $0x802694,(%esp)
  8002c5:	e8 25 04 00 00       	call   8006ef <cprintf>
  8002ca:	8b 43 24             	mov    0x24(%ebx),%eax
  8002cd:	39 46 24             	cmp    %eax,0x24(%esi)
  8002d0:	75 0e                	jne    8002e0 <check_regs+0x2ad>
  8002d2:	c7 04 24 a4 26 80 00 	movl   $0x8026a4,(%esp)
  8002d9:	e8 11 04 00 00       	call   8006ef <cprintf>
  8002de:	eb 11                	jmp    8002f1 <check_regs+0x2be>
  8002e0:	c7 04 24 a8 26 80 00 	movl   $0x8026a8,(%esp)
  8002e7:	e8 03 04 00 00       	call   8006ef <cprintf>
  8002ec:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002f1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f8:	8b 46 28             	mov    0x28(%esi),%eax
  8002fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ff:	c7 44 24 04 d5 26 80 	movl   $0x8026d5,0x4(%esp)
  800306:	00 
  800307:	c7 04 24 94 26 80 00 	movl   $0x802694,(%esp)
  80030e:	e8 dc 03 00 00       	call   8006ef <cprintf>
  800313:	8b 43 28             	mov    0x28(%ebx),%eax
  800316:	39 46 28             	cmp    %eax,0x28(%esi)
  800319:	75 25                	jne    800340 <check_regs+0x30d>
  80031b:	c7 04 24 a4 26 80 00 	movl   $0x8026a4,(%esp)
  800322:	e8 c8 03 00 00       	call   8006ef <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800327:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032e:	c7 04 24 d9 26 80 00 	movl   $0x8026d9,(%esp)
  800335:	e8 b5 03 00 00       	call   8006ef <cprintf>
	if (!mismatch)
  80033a:	85 ff                	test   %edi,%edi
  80033c:	74 23                	je     800361 <check_regs+0x32e>
  80033e:	eb 2f                	jmp    80036f <check_regs+0x33c>
	CHECK(esp, esp);
  800340:	c7 04 24 a8 26 80 00 	movl   $0x8026a8,(%esp)
  800347:	e8 a3 03 00 00       	call   8006ef <cprintf>
	cprintf("Registers %s ", testname);
  80034c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80034f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800353:	c7 04 24 d9 26 80 00 	movl   $0x8026d9,(%esp)
  80035a:	e8 90 03 00 00       	call   8006ef <cprintf>
  80035f:	eb 0e                	jmp    80036f <check_regs+0x33c>
		cprintf("OK\n");
  800361:	c7 04 24 a4 26 80 00 	movl   $0x8026a4,(%esp)
  800368:	e8 82 03 00 00       	call   8006ef <cprintf>
  80036d:	eb 0c                	jmp    80037b <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  80036f:	c7 04 24 a8 26 80 00 	movl   $0x8026a8,(%esp)
  800376:	e8 74 03 00 00       	call   8006ef <cprintf>
}
  80037b:	83 c4 1c             	add    $0x1c,%esp
  80037e:	5b                   	pop    %ebx
  80037f:	5e                   	pop    %esi
  800380:	5f                   	pop    %edi
  800381:	5d                   	pop    %ebp
  800382:	c3                   	ret    

00800383 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	83 ec 28             	sub    $0x28,%esp
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  80038c:	8b 10                	mov    (%eax),%edx
  80038e:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  800394:	74 27                	je     8003bd <pgfault+0x3a>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  800396:	8b 40 28             	mov    0x28(%eax),%eax
  800399:	89 44 24 10          	mov    %eax,0x10(%esp)
  80039d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a1:	c7 44 24 08 40 27 80 	movl   $0x802740,0x8(%esp)
  8003a8:	00 
  8003a9:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8003b0:	00 
  8003b1:	c7 04 24 e7 26 80 00 	movl   $0x8026e7,(%esp)
  8003b8:	e8 39 02 00 00       	call   8005f6 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003bd:	8b 50 08             	mov    0x8(%eax),%edx
  8003c0:	89 15 40 40 80 00    	mov    %edx,0x804040
  8003c6:	8b 50 0c             	mov    0xc(%eax),%edx
  8003c9:	89 15 44 40 80 00    	mov    %edx,0x804044
  8003cf:	8b 50 10             	mov    0x10(%eax),%edx
  8003d2:	89 15 48 40 80 00    	mov    %edx,0x804048
  8003d8:	8b 50 14             	mov    0x14(%eax),%edx
  8003db:	89 15 4c 40 80 00    	mov    %edx,0x80404c
  8003e1:	8b 50 18             	mov    0x18(%eax),%edx
  8003e4:	89 15 50 40 80 00    	mov    %edx,0x804050
  8003ea:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003ed:	89 15 54 40 80 00    	mov    %edx,0x804054
  8003f3:	8b 50 20             	mov    0x20(%eax),%edx
  8003f6:	89 15 58 40 80 00    	mov    %edx,0x804058
  8003fc:	8b 50 24             	mov    0x24(%eax),%edx
  8003ff:	89 15 5c 40 80 00    	mov    %edx,0x80405c
	during.eip = utf->utf_eip;
  800405:	8b 50 28             	mov    0x28(%eax),%edx
  800408:	89 15 60 40 80 00    	mov    %edx,0x804060
	during.eflags = utf->utf_eflags;
  80040e:	8b 50 2c             	mov    0x2c(%eax),%edx
  800411:	89 15 64 40 80 00    	mov    %edx,0x804064
	during.esp = utf->utf_esp;
  800417:	8b 40 30             	mov    0x30(%eax),%eax
  80041a:	a3 68 40 80 00       	mov    %eax,0x804068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  80041f:	c7 44 24 04 ff 26 80 	movl   $0x8026ff,0x4(%esp)
  800426:	00 
  800427:	c7 04 24 0d 27 80 00 	movl   $0x80270d,(%esp)
  80042e:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800433:	ba f8 26 80 00       	mov    $0x8026f8,%edx
  800438:	b8 80 40 80 00       	mov    $0x804080,%eax
  80043d:	e8 f1 fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800442:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800449:	00 
  80044a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  800451:	00 
  800452:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800459:	e8 9b 0d 00 00       	call   8011f9 <sys_page_alloc>
  80045e:	85 c0                	test   %eax,%eax
  800460:	79 20                	jns    800482 <pgfault+0xff>
		panic("sys_page_alloc: %e", r);
  800462:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800466:	c7 44 24 08 14 27 80 	movl   $0x802714,0x8(%esp)
  80046d:	00 
  80046e:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800475:	00 
  800476:	c7 04 24 e7 26 80 00 	movl   $0x8026e7,(%esp)
  80047d:	e8 74 01 00 00       	call   8005f6 <_panic>
}
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <umain>:

void
umain(int argc, char **argv)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  80048a:	c7 04 24 83 03 80 00 	movl   $0x800383,(%esp)
  800491:	e8 cb 0f 00 00       	call   801461 <set_pgfault_handler>

	__asm __volatile(
  800496:	50                   	push   %eax
  800497:	9c                   	pushf  
  800498:	58                   	pop    %eax
  800499:	0d d5 08 00 00       	or     $0x8d5,%eax
  80049e:	50                   	push   %eax
  80049f:	9d                   	popf   
  8004a0:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  8004a5:	8d 05 e0 04 80 00    	lea    0x8004e0,%eax
  8004ab:	a3 a0 40 80 00       	mov    %eax,0x8040a0
  8004b0:	58                   	pop    %eax
  8004b1:	89 3d 80 40 80 00    	mov    %edi,0x804080
  8004b7:	89 35 84 40 80 00    	mov    %esi,0x804084
  8004bd:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  8004c3:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  8004c9:	89 15 94 40 80 00    	mov    %edx,0x804094
  8004cf:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  8004d5:	a3 9c 40 80 00       	mov    %eax,0x80409c
  8004da:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  8004e0:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004e7:	00 00 00 
  8004ea:	89 3d 00 40 80 00    	mov    %edi,0x804000
  8004f0:	89 35 04 40 80 00    	mov    %esi,0x804004
  8004f6:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  8004fc:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  800502:	89 15 14 40 80 00    	mov    %edx,0x804014
  800508:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  80050e:	a3 1c 40 80 00       	mov    %eax,0x80401c
  800513:	89 25 28 40 80 00    	mov    %esp,0x804028
  800519:	8b 3d 80 40 80 00    	mov    0x804080,%edi
  80051f:	8b 35 84 40 80 00    	mov    0x804084,%esi
  800525:	8b 2d 88 40 80 00    	mov    0x804088,%ebp
  80052b:	8b 1d 90 40 80 00    	mov    0x804090,%ebx
  800531:	8b 15 94 40 80 00    	mov    0x804094,%edx
  800537:	8b 0d 98 40 80 00    	mov    0x804098,%ecx
  80053d:	a1 9c 40 80 00       	mov    0x80409c,%eax
  800542:	8b 25 a8 40 80 00    	mov    0x8040a8,%esp
  800548:	50                   	push   %eax
  800549:	9c                   	pushf  
  80054a:	58                   	pop    %eax
  80054b:	a3 24 40 80 00       	mov    %eax,0x804024
  800550:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800551:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800558:	74 0c                	je     800566 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  80055a:	c7 04 24 74 27 80 00 	movl   $0x802774,(%esp)
  800561:	e8 89 01 00 00       	call   8006ef <cprintf>
	after.eip = before.eip;
  800566:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  80056b:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  800570:	c7 44 24 04 27 27 80 	movl   $0x802727,0x4(%esp)
  800577:	00 
  800578:	c7 04 24 38 27 80 00 	movl   $0x802738,(%esp)
  80057f:	b9 00 40 80 00       	mov    $0x804000,%ecx
  800584:	ba f8 26 80 00       	mov    $0x8026f8,%edx
  800589:	b8 80 40 80 00       	mov    $0x804080,%eax
  80058e:	e8 a0 fa ff ff       	call   800033 <check_regs>
}
  800593:	c9                   	leave  
  800594:	c3                   	ret    

00800595 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800595:	55                   	push   %ebp
  800596:	89 e5                	mov    %esp,%ebp
  800598:	56                   	push   %esi
  800599:	53                   	push   %ebx
  80059a:	83 ec 10             	sub    $0x10,%esp
  80059d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005a0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8005a3:	e8 13 0c 00 00       	call   8011bb <sys_getenvid>
  8005a8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005ad:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005b0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005b5:	a3 b0 40 80 00       	mov    %eax,0x8040b0

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005ba:	85 db                	test   %ebx,%ebx
  8005bc:	7e 07                	jle    8005c5 <libmain+0x30>
		binaryname = argv[0];
  8005be:	8b 06                	mov    (%esi),%eax
  8005c0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8005c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005c9:	89 1c 24             	mov    %ebx,(%esp)
  8005cc:	e8 b3 fe ff ff       	call   800484 <umain>

	// exit gracefully
	exit();
  8005d1:	e8 07 00 00 00       	call   8005dd <exit>
}
  8005d6:	83 c4 10             	add    $0x10,%esp
  8005d9:	5b                   	pop    %ebx
  8005da:	5e                   	pop    %esi
  8005db:	5d                   	pop    %ebp
  8005dc:	c3                   	ret    

008005dd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005dd:	55                   	push   %ebp
  8005de:	89 e5                	mov    %esp,%ebp
  8005e0:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8005e3:	e8 3e 11 00 00       	call   801726 <close_all>
	sys_env_destroy(0);
  8005e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005ef:	e8 75 0b 00 00       	call   801169 <sys_env_destroy>
}
  8005f4:	c9                   	leave  
  8005f5:	c3                   	ret    

008005f6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005f6:	55                   	push   %ebp
  8005f7:	89 e5                	mov    %esp,%ebp
  8005f9:	56                   	push   %esi
  8005fa:	53                   	push   %ebx
  8005fb:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8005fe:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800601:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800607:	e8 af 0b 00 00       	call   8011bb <sys_getenvid>
  80060c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80060f:	89 54 24 10          	mov    %edx,0x10(%esp)
  800613:	8b 55 08             	mov    0x8(%ebp),%edx
  800616:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80061a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80061e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800622:	c7 04 24 a0 27 80 00 	movl   $0x8027a0,(%esp)
  800629:	e8 c1 00 00 00       	call   8006ef <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80062e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800632:	8b 45 10             	mov    0x10(%ebp),%eax
  800635:	89 04 24             	mov    %eax,(%esp)
  800638:	e8 51 00 00 00       	call   80068e <vcprintf>
	cprintf("\n");
  80063d:	c7 04 24 b0 26 80 00 	movl   $0x8026b0,(%esp)
  800644:	e8 a6 00 00 00       	call   8006ef <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800649:	cc                   	int3   
  80064a:	eb fd                	jmp    800649 <_panic+0x53>

0080064c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80064c:	55                   	push   %ebp
  80064d:	89 e5                	mov    %esp,%ebp
  80064f:	53                   	push   %ebx
  800650:	83 ec 14             	sub    $0x14,%esp
  800653:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800656:	8b 13                	mov    (%ebx),%edx
  800658:	8d 42 01             	lea    0x1(%edx),%eax
  80065b:	89 03                	mov    %eax,(%ebx)
  80065d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800660:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800664:	3d ff 00 00 00       	cmp    $0xff,%eax
  800669:	75 19                	jne    800684 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80066b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800672:	00 
  800673:	8d 43 08             	lea    0x8(%ebx),%eax
  800676:	89 04 24             	mov    %eax,(%esp)
  800679:	e8 ae 0a 00 00       	call   80112c <sys_cputs>
		b->idx = 0;
  80067e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800684:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800688:	83 c4 14             	add    $0x14,%esp
  80068b:	5b                   	pop    %ebx
  80068c:	5d                   	pop    %ebp
  80068d:	c3                   	ret    

0080068e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80068e:	55                   	push   %ebp
  80068f:	89 e5                	mov    %esp,%ebp
  800691:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800697:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80069e:	00 00 00 
	b.cnt = 0;
  8006a1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006a8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006b9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c3:	c7 04 24 4c 06 80 00 	movl   $0x80064c,(%esp)
  8006ca:	e8 b5 01 00 00       	call   800884 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006cf:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006df:	89 04 24             	mov    %eax,(%esp)
  8006e2:	e8 45 0a 00 00       	call   80112c <sys_cputs>

	return b.cnt;
}
  8006e7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006ed:	c9                   	leave  
  8006ee:	c3                   	ret    

008006ef <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006ef:	55                   	push   %ebp
  8006f0:	89 e5                	mov    %esp,%ebp
  8006f2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006f5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ff:	89 04 24             	mov    %eax,(%esp)
  800702:	e8 87 ff ff ff       	call   80068e <vcprintf>
	va_end(ap);

	return cnt;
}
  800707:	c9                   	leave  
  800708:	c3                   	ret    
  800709:	66 90                	xchg   %ax,%ax
  80070b:	66 90                	xchg   %ax,%ax
  80070d:	66 90                	xchg   %ax,%ax
  80070f:	90                   	nop

00800710 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	57                   	push   %edi
  800714:	56                   	push   %esi
  800715:	53                   	push   %ebx
  800716:	83 ec 3c             	sub    $0x3c,%esp
  800719:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80071c:	89 d7                	mov    %edx,%edi
  80071e:	8b 45 08             	mov    0x8(%ebp),%eax
  800721:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800724:	8b 75 0c             	mov    0xc(%ebp),%esi
  800727:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  80072a:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80072d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800732:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800735:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800738:	39 f1                	cmp    %esi,%ecx
  80073a:	72 14                	jb     800750 <printnum+0x40>
  80073c:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  80073f:	76 0f                	jbe    800750 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800741:	8b 45 14             	mov    0x14(%ebp),%eax
  800744:	8d 70 ff             	lea    -0x1(%eax),%esi
  800747:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80074a:	85 f6                	test   %esi,%esi
  80074c:	7f 60                	jg     8007ae <printnum+0x9e>
  80074e:	eb 72                	jmp    8007c2 <printnum+0xb2>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800750:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800753:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800757:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80075a:	8d 51 ff             	lea    -0x1(%ecx),%edx
  80075d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800761:	89 44 24 08          	mov    %eax,0x8(%esp)
  800765:	8b 44 24 08          	mov    0x8(%esp),%eax
  800769:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80076d:	89 c3                	mov    %eax,%ebx
  80076f:	89 d6                	mov    %edx,%esi
  800771:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800774:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800777:	89 54 24 08          	mov    %edx,0x8(%esp)
  80077b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80077f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800782:	89 04 24             	mov    %eax,(%esp)
  800785:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800788:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078c:	e8 4f 1c 00 00       	call   8023e0 <__udivdi3>
  800791:	89 d9                	mov    %ebx,%ecx
  800793:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800797:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80079b:	89 04 24             	mov    %eax,(%esp)
  80079e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007a2:	89 fa                	mov    %edi,%edx
  8007a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007a7:	e8 64 ff ff ff       	call   800710 <printnum>
  8007ac:	eb 14                	jmp    8007c2 <printnum+0xb2>
			putch(padc, putdat);
  8007ae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007b2:	8b 45 18             	mov    0x18(%ebp),%eax
  8007b5:	89 04 24             	mov    %eax,(%esp)
  8007b8:	ff d3                	call   *%ebx
		while (--width > 0)
  8007ba:	83 ee 01             	sub    $0x1,%esi
  8007bd:	75 ef                	jne    8007ae <printnum+0x9e>
  8007bf:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007c6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8007ca:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007cd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007db:	89 04 24             	mov    %eax,(%esp)
  8007de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e5:	e8 26 1d 00 00       	call   802510 <__umoddi3>
  8007ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ee:	0f be 80 c3 27 80 00 	movsbl 0x8027c3(%eax),%eax
  8007f5:	89 04 24             	mov    %eax,(%esp)
  8007f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007fb:	ff d0                	call   *%eax
}
  8007fd:	83 c4 3c             	add    $0x3c,%esp
  800800:	5b                   	pop    %ebx
  800801:	5e                   	pop    %esi
  800802:	5f                   	pop    %edi
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    

00800805 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800808:	83 fa 01             	cmp    $0x1,%edx
  80080b:	7e 0e                	jle    80081b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80080d:	8b 10                	mov    (%eax),%edx
  80080f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800812:	89 08                	mov    %ecx,(%eax)
  800814:	8b 02                	mov    (%edx),%eax
  800816:	8b 52 04             	mov    0x4(%edx),%edx
  800819:	eb 22                	jmp    80083d <getuint+0x38>
	else if (lflag)
  80081b:	85 d2                	test   %edx,%edx
  80081d:	74 10                	je     80082f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80081f:	8b 10                	mov    (%eax),%edx
  800821:	8d 4a 04             	lea    0x4(%edx),%ecx
  800824:	89 08                	mov    %ecx,(%eax)
  800826:	8b 02                	mov    (%edx),%eax
  800828:	ba 00 00 00 00       	mov    $0x0,%edx
  80082d:	eb 0e                	jmp    80083d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80082f:	8b 10                	mov    (%eax),%edx
  800831:	8d 4a 04             	lea    0x4(%edx),%ecx
  800834:	89 08                	mov    %ecx,(%eax)
  800836:	8b 02                	mov    (%edx),%eax
  800838:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800845:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800849:	8b 10                	mov    (%eax),%edx
  80084b:	3b 50 04             	cmp    0x4(%eax),%edx
  80084e:	73 0a                	jae    80085a <sprintputch+0x1b>
		*b->buf++ = ch;
  800850:	8d 4a 01             	lea    0x1(%edx),%ecx
  800853:	89 08                	mov    %ecx,(%eax)
  800855:	8b 45 08             	mov    0x8(%ebp),%eax
  800858:	88 02                	mov    %al,(%edx)
}
  80085a:	5d                   	pop    %ebp
  80085b:	c3                   	ret    

0080085c <printfmt>:
{
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  800862:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800865:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800869:	8b 45 10             	mov    0x10(%ebp),%eax
  80086c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800870:	8b 45 0c             	mov    0xc(%ebp),%eax
  800873:	89 44 24 04          	mov    %eax,0x4(%esp)
  800877:	8b 45 08             	mov    0x8(%ebp),%eax
  80087a:	89 04 24             	mov    %eax,(%esp)
  80087d:	e8 02 00 00 00       	call   800884 <vprintfmt>
}
  800882:	c9                   	leave  
  800883:	c3                   	ret    

00800884 <vprintfmt>:
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	57                   	push   %edi
  800888:	56                   	push   %esi
  800889:	53                   	push   %ebx
  80088a:	83 ec 3c             	sub    $0x3c,%esp
  80088d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800890:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800893:	eb 18                	jmp    8008ad <vprintfmt+0x29>
			if (ch == '\0')
  800895:	85 c0                	test   %eax,%eax
  800897:	0f 84 c3 03 00 00    	je     800c60 <vprintfmt+0x3dc>
			putch(ch, putdat);
  80089d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008a1:	89 04 24             	mov    %eax,(%esp)
  8008a4:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008a7:	89 f3                	mov    %esi,%ebx
  8008a9:	eb 02                	jmp    8008ad <vprintfmt+0x29>
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ab:	89 f3                	mov    %esi,%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008ad:	8d 73 01             	lea    0x1(%ebx),%esi
  8008b0:	0f b6 03             	movzbl (%ebx),%eax
  8008b3:	83 f8 25             	cmp    $0x25,%eax
  8008b6:	75 dd                	jne    800895 <vprintfmt+0x11>
  8008b8:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8008bc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8008c3:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8008ca:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8008d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8008d6:	eb 1d                	jmp    8008f5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  8008d8:	89 de                	mov    %ebx,%esi
			padc = '-';
  8008da:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  8008de:	eb 15                	jmp    8008f5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  8008e0:	89 de                	mov    %ebx,%esi
			padc = '0';
  8008e2:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  8008e6:	eb 0d                	jmp    8008f5 <vprintfmt+0x71>
				width = precision, precision = -1;
  8008e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8008eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008ee:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008f5:	8d 5e 01             	lea    0x1(%esi),%ebx
  8008f8:	0f b6 06             	movzbl (%esi),%eax
  8008fb:	0f b6 c8             	movzbl %al,%ecx
  8008fe:	83 e8 23             	sub    $0x23,%eax
  800901:	3c 55                	cmp    $0x55,%al
  800903:	0f 87 2f 03 00 00    	ja     800c38 <vprintfmt+0x3b4>
  800909:	0f b6 c0             	movzbl %al,%eax
  80090c:	ff 24 85 00 29 80 00 	jmp    *0x802900(,%eax,4)
				precision = precision * 10 + ch - '0';
  800913:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800916:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
  800919:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80091d:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800920:	83 f9 09             	cmp    $0x9,%ecx
  800923:	77 50                	ja     800975 <vprintfmt+0xf1>
		switch (ch = *(unsigned char *) fmt++) {
  800925:	89 de                	mov    %ebx,%esi
  800927:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			for (precision = 0; ; ++fmt) {
  80092a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80092d:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800930:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800934:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800937:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80093a:	83 fb 09             	cmp    $0x9,%ebx
  80093d:	76 eb                	jbe    80092a <vprintfmt+0xa6>
  80093f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800942:	eb 33                	jmp    800977 <vprintfmt+0xf3>
			precision = va_arg(ap, int);
  800944:	8b 45 14             	mov    0x14(%ebp),%eax
  800947:	8d 48 04             	lea    0x4(%eax),%ecx
  80094a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80094d:	8b 00                	mov    (%eax),%eax
  80094f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800952:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800954:	eb 21                	jmp    800977 <vprintfmt+0xf3>
  800956:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800959:	85 c9                	test   %ecx,%ecx
  80095b:	b8 00 00 00 00       	mov    $0x0,%eax
  800960:	0f 49 c1             	cmovns %ecx,%eax
  800963:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800966:	89 de                	mov    %ebx,%esi
  800968:	eb 8b                	jmp    8008f5 <vprintfmt+0x71>
  80096a:	89 de                	mov    %ebx,%esi
			altflag = 1;
  80096c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800973:	eb 80                	jmp    8008f5 <vprintfmt+0x71>
		switch (ch = *(unsigned char *) fmt++) {
  800975:	89 de                	mov    %ebx,%esi
			if (width < 0)
  800977:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80097b:	0f 89 74 ff ff ff    	jns    8008f5 <vprintfmt+0x71>
  800981:	e9 62 ff ff ff       	jmp    8008e8 <vprintfmt+0x64>
			lflag++;
  800986:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  800989:	89 de                	mov    %ebx,%esi
			goto reswitch;
  80098b:	e9 65 ff ff ff       	jmp    8008f5 <vprintfmt+0x71>
			putch(va_arg(ap, int), putdat);
  800990:	8b 45 14             	mov    0x14(%ebp),%eax
  800993:	8d 50 04             	lea    0x4(%eax),%edx
  800996:	89 55 14             	mov    %edx,0x14(%ebp)
  800999:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80099d:	8b 00                	mov    (%eax),%eax
  80099f:	89 04 24             	mov    %eax,(%esp)
  8009a2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8009a5:	e9 03 ff ff ff       	jmp    8008ad <vprintfmt+0x29>
			err = va_arg(ap, int);
  8009aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ad:	8d 50 04             	lea    0x4(%eax),%edx
  8009b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b3:	8b 00                	mov    (%eax),%eax
  8009b5:	99                   	cltd   
  8009b6:	31 d0                	xor    %edx,%eax
  8009b8:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009ba:	83 f8 0f             	cmp    $0xf,%eax
  8009bd:	7f 0b                	jg     8009ca <vprintfmt+0x146>
  8009bf:	8b 14 85 60 2a 80 00 	mov    0x802a60(,%eax,4),%edx
  8009c6:	85 d2                	test   %edx,%edx
  8009c8:	75 20                	jne    8009ea <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  8009ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ce:	c7 44 24 08 db 27 80 	movl   $0x8027db,0x8(%esp)
  8009d5:	00 
  8009d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	89 04 24             	mov    %eax,(%esp)
  8009e0:	e8 77 fe ff ff       	call   80085c <printfmt>
  8009e5:	e9 c3 fe ff ff       	jmp    8008ad <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  8009ea:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009ee:	c7 44 24 08 f6 2b 80 	movl   $0x802bf6,0x8(%esp)
  8009f5:	00 
  8009f6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	89 04 24             	mov    %eax,(%esp)
  800a00:	e8 57 fe ff ff       	call   80085c <printfmt>
  800a05:	e9 a3 fe ff ff       	jmp    8008ad <vprintfmt+0x29>
		switch (ch = *(unsigned char *) fmt++) {
  800a0a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800a0d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
  800a10:	8b 45 14             	mov    0x14(%ebp),%eax
  800a13:	8d 50 04             	lea    0x4(%eax),%edx
  800a16:	89 55 14             	mov    %edx,0x14(%ebp)
  800a19:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  800a1b:	85 c0                	test   %eax,%eax
  800a1d:	ba d4 27 80 00       	mov    $0x8027d4,%edx
  800a22:	0f 45 d0             	cmovne %eax,%edx
  800a25:	89 55 d0             	mov    %edx,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800a28:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800a2c:	74 04                	je     800a32 <vprintfmt+0x1ae>
  800a2e:	85 f6                	test   %esi,%esi
  800a30:	7f 19                	jg     800a4b <vprintfmt+0x1c7>
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a32:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a35:	8d 70 01             	lea    0x1(%eax),%esi
  800a38:	0f b6 10             	movzbl (%eax),%edx
  800a3b:	0f be c2             	movsbl %dl,%eax
  800a3e:	85 c0                	test   %eax,%eax
  800a40:	0f 85 95 00 00 00    	jne    800adb <vprintfmt+0x257>
  800a46:	e9 85 00 00 00       	jmp    800ad0 <vprintfmt+0x24c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a4b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a4f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a52:	89 04 24             	mov    %eax,(%esp)
  800a55:	e8 b8 02 00 00       	call   800d12 <strnlen>
  800a5a:	29 c6                	sub    %eax,%esi
  800a5c:	89 f0                	mov    %esi,%eax
  800a5e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800a61:	85 f6                	test   %esi,%esi
  800a63:	7e cd                	jle    800a32 <vprintfmt+0x1ae>
					putch(padc, putdat);
  800a65:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800a69:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a6c:	89 c3                	mov    %eax,%ebx
  800a6e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a72:	89 34 24             	mov    %esi,(%esp)
  800a75:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800a78:	83 eb 01             	sub    $0x1,%ebx
  800a7b:	75 f1                	jne    800a6e <vprintfmt+0x1ea>
  800a7d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800a80:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a83:	eb ad                	jmp    800a32 <vprintfmt+0x1ae>
				if (altflag && (ch < ' ' || ch > '~'))
  800a85:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a89:	74 1e                	je     800aa9 <vprintfmt+0x225>
  800a8b:	0f be d2             	movsbl %dl,%edx
  800a8e:	83 ea 20             	sub    $0x20,%edx
  800a91:	83 fa 5e             	cmp    $0x5e,%edx
  800a94:	76 13                	jbe    800aa9 <vprintfmt+0x225>
					putch('?', putdat);
  800a96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a99:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a9d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800aa4:	ff 55 08             	call   *0x8(%ebp)
  800aa7:	eb 0d                	jmp    800ab6 <vprintfmt+0x232>
					putch(ch, putdat);
  800aa9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aac:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ab0:	89 04 24             	mov    %eax,(%esp)
  800ab3:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ab6:	83 ef 01             	sub    $0x1,%edi
  800ab9:	83 c6 01             	add    $0x1,%esi
  800abc:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800ac0:	0f be c2             	movsbl %dl,%eax
  800ac3:	85 c0                	test   %eax,%eax
  800ac5:	75 20                	jne    800ae7 <vprintfmt+0x263>
  800ac7:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800aca:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800acd:	8b 5d 10             	mov    0x10(%ebp),%ebx
			for (; width > 0; width--)
  800ad0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ad4:	7f 25                	jg     800afb <vprintfmt+0x277>
  800ad6:	e9 d2 fd ff ff       	jmp    8008ad <vprintfmt+0x29>
  800adb:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800ade:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ae1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ae4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ae7:	85 db                	test   %ebx,%ebx
  800ae9:	78 9a                	js     800a85 <vprintfmt+0x201>
  800aeb:	83 eb 01             	sub    $0x1,%ebx
  800aee:	79 95                	jns    800a85 <vprintfmt+0x201>
  800af0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800af3:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800af6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800af9:	eb d5                	jmp    800ad0 <vprintfmt+0x24c>
  800afb:	8b 75 08             	mov    0x8(%ebp),%esi
  800afe:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b01:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				putch(' ', putdat);
  800b04:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b08:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800b0f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800b11:	83 eb 01             	sub    $0x1,%ebx
  800b14:	75 ee                	jne    800b04 <vprintfmt+0x280>
  800b16:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b19:	e9 8f fd ff ff       	jmp    8008ad <vprintfmt+0x29>
	if (lflag >= 2)
  800b1e:	83 fa 01             	cmp    $0x1,%edx
  800b21:	7e 16                	jle    800b39 <vprintfmt+0x2b5>
		return va_arg(*ap, long long);
  800b23:	8b 45 14             	mov    0x14(%ebp),%eax
  800b26:	8d 50 08             	lea    0x8(%eax),%edx
  800b29:	89 55 14             	mov    %edx,0x14(%ebp)
  800b2c:	8b 50 04             	mov    0x4(%eax),%edx
  800b2f:	8b 00                	mov    (%eax),%eax
  800b31:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b34:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b37:	eb 32                	jmp    800b6b <vprintfmt+0x2e7>
	else if (lflag)
  800b39:	85 d2                	test   %edx,%edx
  800b3b:	74 18                	je     800b55 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  800b3d:	8b 45 14             	mov    0x14(%ebp),%eax
  800b40:	8d 50 04             	lea    0x4(%eax),%edx
  800b43:	89 55 14             	mov    %edx,0x14(%ebp)
  800b46:	8b 30                	mov    (%eax),%esi
  800b48:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800b4b:	89 f0                	mov    %esi,%eax
  800b4d:	c1 f8 1f             	sar    $0x1f,%eax
  800b50:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800b53:	eb 16                	jmp    800b6b <vprintfmt+0x2e7>
		return va_arg(*ap, int);
  800b55:	8b 45 14             	mov    0x14(%ebp),%eax
  800b58:	8d 50 04             	lea    0x4(%eax),%edx
  800b5b:	89 55 14             	mov    %edx,0x14(%ebp)
  800b5e:	8b 30                	mov    (%eax),%esi
  800b60:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800b63:	89 f0                	mov    %esi,%eax
  800b65:	c1 f8 1f             	sar    $0x1f,%eax
  800b68:	89 45 dc             	mov    %eax,-0x24(%ebp)
			num = getint(&ap, lflag);
  800b6b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b6e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			base = 10;
  800b71:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800b76:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b7a:	0f 89 80 00 00 00    	jns    800c00 <vprintfmt+0x37c>
				putch('-', putdat);
  800b80:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b84:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b8b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800b8e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b91:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800b94:	f7 d8                	neg    %eax
  800b96:	83 d2 00             	adc    $0x0,%edx
  800b99:	f7 da                	neg    %edx
			base = 10;
  800b9b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800ba0:	eb 5e                	jmp    800c00 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800ba2:	8d 45 14             	lea    0x14(%ebp),%eax
  800ba5:	e8 5b fc ff ff       	call   800805 <getuint>
			base = 10;
  800baa:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800baf:	eb 4f                	jmp    800c00 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800bb1:	8d 45 14             	lea    0x14(%ebp),%eax
  800bb4:	e8 4c fc ff ff       	call   800805 <getuint>
			base = 8;
  800bb9:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800bbe:	eb 40                	jmp    800c00 <vprintfmt+0x37c>
			putch('0', putdat);
  800bc0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bc4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800bcb:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800bce:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bd2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800bd9:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  800bdc:	8b 45 14             	mov    0x14(%ebp),%eax
  800bdf:	8d 50 04             	lea    0x4(%eax),%edx
  800be2:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800be5:	8b 00                	mov    (%eax),%eax
  800be7:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  800bec:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800bf1:	eb 0d                	jmp    800c00 <vprintfmt+0x37c>
			num = getuint(&ap, lflag);
  800bf3:	8d 45 14             	lea    0x14(%ebp),%eax
  800bf6:	e8 0a fc ff ff       	call   800805 <getuint>
			base = 16;
  800bfb:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  800c00:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800c04:	89 74 24 10          	mov    %esi,0x10(%esp)
  800c08:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800c0b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800c0f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c13:	89 04 24             	mov    %eax,(%esp)
  800c16:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c1a:	89 fa                	mov    %edi,%edx
  800c1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1f:	e8 ec fa ff ff       	call   800710 <printnum>
			break;
  800c24:	e9 84 fc ff ff       	jmp    8008ad <vprintfmt+0x29>
			putch(ch, putdat);
  800c29:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c2d:	89 0c 24             	mov    %ecx,(%esp)
  800c30:	ff 55 08             	call   *0x8(%ebp)
			break;
  800c33:	e9 75 fc ff ff       	jmp    8008ad <vprintfmt+0x29>
			putch('%', putdat);
  800c38:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c3c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800c43:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c46:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c4a:	0f 84 5b fc ff ff    	je     8008ab <vprintfmt+0x27>
  800c50:	89 f3                	mov    %esi,%ebx
  800c52:	83 eb 01             	sub    $0x1,%ebx
  800c55:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800c59:	75 f7                	jne    800c52 <vprintfmt+0x3ce>
  800c5b:	e9 4d fc ff ff       	jmp    8008ad <vprintfmt+0x29>
}
  800c60:	83 c4 3c             	add    $0x3c,%esp
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	83 ec 28             	sub    $0x28,%esp
  800c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c71:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c74:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c77:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c7b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c7e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c85:	85 c0                	test   %eax,%eax
  800c87:	74 30                	je     800cb9 <vsnprintf+0x51>
  800c89:	85 d2                	test   %edx,%edx
  800c8b:	7e 2c                	jle    800cb9 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c8d:	8b 45 14             	mov    0x14(%ebp),%eax
  800c90:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c94:	8b 45 10             	mov    0x10(%ebp),%eax
  800c97:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c9b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca2:	c7 04 24 3f 08 80 00 	movl   $0x80083f,(%esp)
  800ca9:	e8 d6 fb ff ff       	call   800884 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cb1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb7:	eb 05                	jmp    800cbe <vsnprintf+0x56>
		return -E_INVAL;
  800cb9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800cbe:	c9                   	leave  
  800cbf:	c3                   	ret    

00800cc0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cc6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ccd:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cde:	89 04 24             	mov    %eax,(%esp)
  800ce1:	e8 82 ff ff ff       	call   800c68 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ce6:	c9                   	leave  
  800ce7:	c3                   	ret    
  800ce8:	66 90                	xchg   %ax,%ax
  800cea:	66 90                	xchg   %ax,%ax
  800cec:	66 90                	xchg   %ax,%ax
  800cee:	66 90                	xchg   %ax,%ax

00800cf0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cf6:	80 3a 00             	cmpb   $0x0,(%edx)
  800cf9:	74 10                	je     800d0b <strlen+0x1b>
  800cfb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800d00:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800d03:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d07:	75 f7                	jne    800d00 <strlen+0x10>
  800d09:	eb 05                	jmp    800d10 <strlen+0x20>
  800d0b:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	53                   	push   %ebx
  800d16:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d1c:	85 c9                	test   %ecx,%ecx
  800d1e:	74 1c                	je     800d3c <strnlen+0x2a>
  800d20:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d23:	74 1e                	je     800d43 <strnlen+0x31>
  800d25:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800d2a:	89 d0                	mov    %edx,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d2c:	39 ca                	cmp    %ecx,%edx
  800d2e:	74 18                	je     800d48 <strnlen+0x36>
  800d30:	83 c2 01             	add    $0x1,%edx
  800d33:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800d38:	75 f0                	jne    800d2a <strnlen+0x18>
  800d3a:	eb 0c                	jmp    800d48 <strnlen+0x36>
  800d3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d41:	eb 05                	jmp    800d48 <strnlen+0x36>
  800d43:	b8 00 00 00 00       	mov    $0x0,%eax
	return n;
}
  800d48:	5b                   	pop    %ebx
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	53                   	push   %ebx
  800d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d55:	89 c2                	mov    %eax,%edx
  800d57:	83 c2 01             	add    $0x1,%edx
  800d5a:	83 c1 01             	add    $0x1,%ecx
  800d5d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d61:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d64:	84 db                	test   %bl,%bl
  800d66:	75 ef                	jne    800d57 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d68:	5b                   	pop    %ebx
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	53                   	push   %ebx
  800d6f:	83 ec 08             	sub    $0x8,%esp
  800d72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d75:	89 1c 24             	mov    %ebx,(%esp)
  800d78:	e8 73 ff ff ff       	call   800cf0 <strlen>
	strcpy(dst + len, src);
  800d7d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d80:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d84:	01 d8                	add    %ebx,%eax
  800d86:	89 04 24             	mov    %eax,(%esp)
  800d89:	e8 bd ff ff ff       	call   800d4b <strcpy>
	return dst;
}
  800d8e:	89 d8                	mov    %ebx,%eax
  800d90:	83 c4 08             	add    $0x8,%esp
  800d93:	5b                   	pop    %ebx
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
  800d9b:	8b 75 08             	mov    0x8(%ebp),%esi
  800d9e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800da1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800da4:	85 db                	test   %ebx,%ebx
  800da6:	74 17                	je     800dbf <strncpy+0x29>
  800da8:	01 f3                	add    %esi,%ebx
  800daa:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800dac:	83 c1 01             	add    $0x1,%ecx
  800daf:	0f b6 02             	movzbl (%edx),%eax
  800db2:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800db5:	80 3a 01             	cmpb   $0x1,(%edx)
  800db8:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800dbb:	39 d9                	cmp    %ebx,%ecx
  800dbd:	75 ed                	jne    800dac <strncpy+0x16>
	}
	return ret;
}
  800dbf:	89 f0                	mov    %esi,%eax
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    

00800dc5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	57                   	push   %edi
  800dc9:	56                   	push   %esi
  800dca:	53                   	push   %ebx
  800dcb:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dd1:	8b 75 10             	mov    0x10(%ebp),%esi
  800dd4:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800dd6:	85 f6                	test   %esi,%esi
  800dd8:	74 34                	je     800e0e <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800dda:	83 fe 01             	cmp    $0x1,%esi
  800ddd:	74 26                	je     800e05 <strlcpy+0x40>
  800ddf:	0f b6 0b             	movzbl (%ebx),%ecx
  800de2:	84 c9                	test   %cl,%cl
  800de4:	74 23                	je     800e09 <strlcpy+0x44>
  800de6:	83 ee 02             	sub    $0x2,%esi
  800de9:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
  800dee:	83 c0 01             	add    $0x1,%eax
  800df1:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800df4:	39 f2                	cmp    %esi,%edx
  800df6:	74 13                	je     800e0b <strlcpy+0x46>
  800df8:	83 c2 01             	add    $0x1,%edx
  800dfb:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800dff:	84 c9                	test   %cl,%cl
  800e01:	75 eb                	jne    800dee <strlcpy+0x29>
  800e03:	eb 06                	jmp    800e0b <strlcpy+0x46>
  800e05:	89 f8                	mov    %edi,%eax
  800e07:	eb 02                	jmp    800e0b <strlcpy+0x46>
  800e09:	89 f8                	mov    %edi,%eax
		*dst = '\0';
  800e0b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e0e:	29 f8                	sub    %edi,%eax
}
  800e10:	5b                   	pop    %ebx
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    

00800e15 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e1b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e1e:	0f b6 01             	movzbl (%ecx),%eax
  800e21:	84 c0                	test   %al,%al
  800e23:	74 15                	je     800e3a <strcmp+0x25>
  800e25:	3a 02                	cmp    (%edx),%al
  800e27:	75 11                	jne    800e3a <strcmp+0x25>
		p++, q++;
  800e29:	83 c1 01             	add    $0x1,%ecx
  800e2c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800e2f:	0f b6 01             	movzbl (%ecx),%eax
  800e32:	84 c0                	test   %al,%al
  800e34:	74 04                	je     800e3a <strcmp+0x25>
  800e36:	3a 02                	cmp    (%edx),%al
  800e38:	74 ef                	je     800e29 <strcmp+0x14>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e3a:	0f b6 c0             	movzbl %al,%eax
  800e3d:	0f b6 12             	movzbl (%edx),%edx
  800e40:	29 d0                	sub    %edx,%eax
}
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    

00800e44 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	56                   	push   %esi
  800e48:	53                   	push   %ebx
  800e49:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e4f:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800e52:	85 f6                	test   %esi,%esi
  800e54:	74 29                	je     800e7f <strncmp+0x3b>
  800e56:	0f b6 03             	movzbl (%ebx),%eax
  800e59:	84 c0                	test   %al,%al
  800e5b:	74 30                	je     800e8d <strncmp+0x49>
  800e5d:	3a 02                	cmp    (%edx),%al
  800e5f:	75 2c                	jne    800e8d <strncmp+0x49>
  800e61:	8d 43 01             	lea    0x1(%ebx),%eax
  800e64:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800e66:	89 c3                	mov    %eax,%ebx
  800e68:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800e6b:	39 f0                	cmp    %esi,%eax
  800e6d:	74 17                	je     800e86 <strncmp+0x42>
  800e6f:	0f b6 08             	movzbl (%eax),%ecx
  800e72:	84 c9                	test   %cl,%cl
  800e74:	74 17                	je     800e8d <strncmp+0x49>
  800e76:	83 c0 01             	add    $0x1,%eax
  800e79:	3a 0a                	cmp    (%edx),%cl
  800e7b:	74 e9                	je     800e66 <strncmp+0x22>
  800e7d:	eb 0e                	jmp    800e8d <strncmp+0x49>
	if (n == 0)
		return 0;
  800e7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e84:	eb 0f                	jmp    800e95 <strncmp+0x51>
  800e86:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8b:	eb 08                	jmp    800e95 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e8d:	0f b6 03             	movzbl (%ebx),%eax
  800e90:	0f b6 12             	movzbl (%edx),%edx
  800e93:	29 d0                	sub    %edx,%eax
}
  800e95:	5b                   	pop    %ebx
  800e96:	5e                   	pop    %esi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	53                   	push   %ebx
  800e9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea0:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800ea3:	0f b6 18             	movzbl (%eax),%ebx
  800ea6:	84 db                	test   %bl,%bl
  800ea8:	74 1d                	je     800ec7 <strchr+0x2e>
  800eaa:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800eac:	38 d3                	cmp    %dl,%bl
  800eae:	75 06                	jne    800eb6 <strchr+0x1d>
  800eb0:	eb 1a                	jmp    800ecc <strchr+0x33>
  800eb2:	38 ca                	cmp    %cl,%dl
  800eb4:	74 16                	je     800ecc <strchr+0x33>
	for (; *s; s++)
  800eb6:	83 c0 01             	add    $0x1,%eax
  800eb9:	0f b6 10             	movzbl (%eax),%edx
  800ebc:	84 d2                	test   %dl,%dl
  800ebe:	75 f2                	jne    800eb2 <strchr+0x19>
			return (char *) s;
	return 0;
  800ec0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec5:	eb 05                	jmp    800ecc <strchr+0x33>
  800ec7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ecc:	5b                   	pop    %ebx
  800ecd:	5d                   	pop    %ebp
  800ece:	c3                   	ret    

00800ecf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	53                   	push   %ebx
  800ed3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed6:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800ed9:	0f b6 18             	movzbl (%eax),%ebx
  800edc:	84 db                	test   %bl,%bl
  800ede:	74 16                	je     800ef6 <strfind+0x27>
  800ee0:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800ee2:	38 d3                	cmp    %dl,%bl
  800ee4:	75 06                	jne    800eec <strfind+0x1d>
  800ee6:	eb 0e                	jmp    800ef6 <strfind+0x27>
  800ee8:	38 ca                	cmp    %cl,%dl
  800eea:	74 0a                	je     800ef6 <strfind+0x27>
	for (; *s; s++)
  800eec:	83 c0 01             	add    $0x1,%eax
  800eef:	0f b6 10             	movzbl (%eax),%edx
  800ef2:	84 d2                	test   %dl,%dl
  800ef4:	75 f2                	jne    800ee8 <strfind+0x19>
			break;
	return (char *) s;
}
  800ef6:	5b                   	pop    %ebx
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    

00800ef9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	57                   	push   %edi
  800efd:	56                   	push   %esi
  800efe:	53                   	push   %ebx
  800eff:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f05:	85 c9                	test   %ecx,%ecx
  800f07:	74 36                	je     800f3f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f09:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f0f:	75 28                	jne    800f39 <memset+0x40>
  800f11:	f6 c1 03             	test   $0x3,%cl
  800f14:	75 23                	jne    800f39 <memset+0x40>
		c &= 0xFF;
  800f16:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f1a:	89 d3                	mov    %edx,%ebx
  800f1c:	c1 e3 08             	shl    $0x8,%ebx
  800f1f:	89 d6                	mov    %edx,%esi
  800f21:	c1 e6 18             	shl    $0x18,%esi
  800f24:	89 d0                	mov    %edx,%eax
  800f26:	c1 e0 10             	shl    $0x10,%eax
  800f29:	09 f0                	or     %esi,%eax
  800f2b:	09 c2                	or     %eax,%edx
  800f2d:	89 d0                	mov    %edx,%eax
  800f2f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800f31:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800f34:	fc                   	cld    
  800f35:	f3 ab                	rep stos %eax,%es:(%edi)
  800f37:	eb 06                	jmp    800f3f <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3c:	fc                   	cld    
  800f3d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f3f:	89 f8                	mov    %edi,%eax
  800f41:	5b                   	pop    %ebx
  800f42:	5e                   	pop    %esi
  800f43:	5f                   	pop    %edi
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    

00800f46 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	57                   	push   %edi
  800f4a:	56                   	push   %esi
  800f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f51:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f54:	39 c6                	cmp    %eax,%esi
  800f56:	73 35                	jae    800f8d <memmove+0x47>
  800f58:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f5b:	39 d0                	cmp    %edx,%eax
  800f5d:	73 2e                	jae    800f8d <memmove+0x47>
		s += n;
		d += n;
  800f5f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800f62:	89 d6                	mov    %edx,%esi
  800f64:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f66:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f6c:	75 13                	jne    800f81 <memmove+0x3b>
  800f6e:	f6 c1 03             	test   $0x3,%cl
  800f71:	75 0e                	jne    800f81 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f73:	83 ef 04             	sub    $0x4,%edi
  800f76:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f79:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800f7c:	fd                   	std    
  800f7d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f7f:	eb 09                	jmp    800f8a <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f81:	83 ef 01             	sub    $0x1,%edi
  800f84:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800f87:	fd                   	std    
  800f88:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f8a:	fc                   	cld    
  800f8b:	eb 1d                	jmp    800faa <memmove+0x64>
  800f8d:	89 f2                	mov    %esi,%edx
  800f8f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f91:	f6 c2 03             	test   $0x3,%dl
  800f94:	75 0f                	jne    800fa5 <memmove+0x5f>
  800f96:	f6 c1 03             	test   $0x3,%cl
  800f99:	75 0a                	jne    800fa5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f9b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800f9e:	89 c7                	mov    %eax,%edi
  800fa0:	fc                   	cld    
  800fa1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fa3:	eb 05                	jmp    800faa <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800fa5:	89 c7                	mov    %eax,%edi
  800fa7:	fc                   	cld    
  800fa8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800faa:	5e                   	pop    %esi
  800fab:	5f                   	pop    %edi
  800fac:	5d                   	pop    %ebp
  800fad:	c3                   	ret    

00800fae <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800fae:	55                   	push   %ebp
  800faf:	89 e5                	mov    %esp,%ebp
  800fb1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800fb4:	8b 45 10             	mov    0x10(%ebp),%eax
  800fb7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc5:	89 04 24             	mov    %eax,(%esp)
  800fc8:	e8 79 ff ff ff       	call   800f46 <memmove>
}
  800fcd:	c9                   	leave  
  800fce:	c3                   	ret    

00800fcf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	57                   	push   %edi
  800fd3:	56                   	push   %esi
  800fd4:	53                   	push   %ebx
  800fd5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fd8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fdb:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fde:	8d 78 ff             	lea    -0x1(%eax),%edi
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	74 36                	je     80101b <memcmp+0x4c>
		if (*s1 != *s2)
  800fe5:	0f b6 03             	movzbl (%ebx),%eax
  800fe8:	0f b6 0e             	movzbl (%esi),%ecx
  800feb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff0:	38 c8                	cmp    %cl,%al
  800ff2:	74 1c                	je     801010 <memcmp+0x41>
  800ff4:	eb 10                	jmp    801006 <memcmp+0x37>
  800ff6:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800ffb:	83 c2 01             	add    $0x1,%edx
  800ffe:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  801002:	38 c8                	cmp    %cl,%al
  801004:	74 0a                	je     801010 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  801006:	0f b6 c0             	movzbl %al,%eax
  801009:	0f b6 c9             	movzbl %cl,%ecx
  80100c:	29 c8                	sub    %ecx,%eax
  80100e:	eb 10                	jmp    801020 <memcmp+0x51>
	while (n-- > 0) {
  801010:	39 fa                	cmp    %edi,%edx
  801012:	75 e2                	jne    800ff6 <memcmp+0x27>
		s1++, s2++;
	}

	return 0;
  801014:	b8 00 00 00 00       	mov    $0x0,%eax
  801019:	eb 05                	jmp    801020 <memcmp+0x51>
  80101b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801020:	5b                   	pop    %ebx
  801021:	5e                   	pop    %esi
  801022:	5f                   	pop    %edi
  801023:	5d                   	pop    %ebp
  801024:	c3                   	ret    

00801025 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
  801028:	53                   	push   %ebx
  801029:	8b 45 08             	mov    0x8(%ebp),%eax
  80102c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  80102f:	89 c2                	mov    %eax,%edx
  801031:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801034:	39 d0                	cmp    %edx,%eax
  801036:	73 13                	jae    80104b <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801038:	89 d9                	mov    %ebx,%ecx
  80103a:	38 18                	cmp    %bl,(%eax)
  80103c:	75 06                	jne    801044 <memfind+0x1f>
  80103e:	eb 0b                	jmp    80104b <memfind+0x26>
  801040:	38 08                	cmp    %cl,(%eax)
  801042:	74 07                	je     80104b <memfind+0x26>
	for (; s < ends; s++)
  801044:	83 c0 01             	add    $0x1,%eax
  801047:	39 d0                	cmp    %edx,%eax
  801049:	75 f5                	jne    801040 <memfind+0x1b>
			break;
	return (void *) s;
}
  80104b:	5b                   	pop    %ebx
  80104c:	5d                   	pop    %ebp
  80104d:	c3                   	ret    

0080104e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	57                   	push   %edi
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
  801054:	8b 55 08             	mov    0x8(%ebp),%edx
  801057:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80105a:	0f b6 0a             	movzbl (%edx),%ecx
  80105d:	80 f9 09             	cmp    $0x9,%cl
  801060:	74 05                	je     801067 <strtol+0x19>
  801062:	80 f9 20             	cmp    $0x20,%cl
  801065:	75 10                	jne    801077 <strtol+0x29>
		s++;
  801067:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  80106a:	0f b6 0a             	movzbl (%edx),%ecx
  80106d:	80 f9 09             	cmp    $0x9,%cl
  801070:	74 f5                	je     801067 <strtol+0x19>
  801072:	80 f9 20             	cmp    $0x20,%cl
  801075:	74 f0                	je     801067 <strtol+0x19>

	// plus/minus sign
	if (*s == '+')
  801077:	80 f9 2b             	cmp    $0x2b,%cl
  80107a:	75 0a                	jne    801086 <strtol+0x38>
		s++;
  80107c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  80107f:	bf 00 00 00 00       	mov    $0x0,%edi
  801084:	eb 11                	jmp    801097 <strtol+0x49>
  801086:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  80108b:	80 f9 2d             	cmp    $0x2d,%cl
  80108e:	75 07                	jne    801097 <strtol+0x49>
		s++, neg = 1;
  801090:	83 c2 01             	add    $0x1,%edx
  801093:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801097:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  80109c:	75 15                	jne    8010b3 <strtol+0x65>
  80109e:	80 3a 30             	cmpb   $0x30,(%edx)
  8010a1:	75 10                	jne    8010b3 <strtol+0x65>
  8010a3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8010a7:	75 0a                	jne    8010b3 <strtol+0x65>
		s += 2, base = 16;
  8010a9:	83 c2 02             	add    $0x2,%edx
  8010ac:	b8 10 00 00 00       	mov    $0x10,%eax
  8010b1:	eb 10                	jmp    8010c3 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	75 0c                	jne    8010c3 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8010b7:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  8010b9:	80 3a 30             	cmpb   $0x30,(%edx)
  8010bc:	75 05                	jne    8010c3 <strtol+0x75>
		s++, base = 8;
  8010be:	83 c2 01             	add    $0x1,%edx
  8010c1:	b0 08                	mov    $0x8,%al
		base = 10;
  8010c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010c8:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010cb:	0f b6 0a             	movzbl (%edx),%ecx
  8010ce:	8d 71 d0             	lea    -0x30(%ecx),%esi
  8010d1:	89 f0                	mov    %esi,%eax
  8010d3:	3c 09                	cmp    $0x9,%al
  8010d5:	77 08                	ja     8010df <strtol+0x91>
			dig = *s - '0';
  8010d7:	0f be c9             	movsbl %cl,%ecx
  8010da:	83 e9 30             	sub    $0x30,%ecx
  8010dd:	eb 20                	jmp    8010ff <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
  8010df:	8d 71 9f             	lea    -0x61(%ecx),%esi
  8010e2:	89 f0                	mov    %esi,%eax
  8010e4:	3c 19                	cmp    $0x19,%al
  8010e6:	77 08                	ja     8010f0 <strtol+0xa2>
			dig = *s - 'a' + 10;
  8010e8:	0f be c9             	movsbl %cl,%ecx
  8010eb:	83 e9 57             	sub    $0x57,%ecx
  8010ee:	eb 0f                	jmp    8010ff <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
  8010f0:	8d 71 bf             	lea    -0x41(%ecx),%esi
  8010f3:	89 f0                	mov    %esi,%eax
  8010f5:	3c 19                	cmp    $0x19,%al
  8010f7:	77 16                	ja     80110f <strtol+0xc1>
			dig = *s - 'A' + 10;
  8010f9:	0f be c9             	movsbl %cl,%ecx
  8010fc:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8010ff:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  801102:	7d 0f                	jge    801113 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801104:	83 c2 01             	add    $0x1,%edx
  801107:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  80110b:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  80110d:	eb bc                	jmp    8010cb <strtol+0x7d>
  80110f:	89 d8                	mov    %ebx,%eax
  801111:	eb 02                	jmp    801115 <strtol+0xc7>
  801113:	89 d8                	mov    %ebx,%eax

	if (endptr)
  801115:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801119:	74 05                	je     801120 <strtol+0xd2>
		*endptr = (char *) s;
  80111b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80111e:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  801120:	f7 d8                	neg    %eax
  801122:	85 ff                	test   %edi,%edi
  801124:	0f 44 c3             	cmove  %ebx,%eax
}
  801127:	5b                   	pop    %ebx
  801128:	5e                   	pop    %esi
  801129:	5f                   	pop    %edi
  80112a:	5d                   	pop    %ebp
  80112b:	c3                   	ret    

0080112c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	57                   	push   %edi
  801130:	56                   	push   %esi
  801131:	53                   	push   %ebx
	asm volatile("int %1\n"
  801132:	b8 00 00 00 00       	mov    $0x0,%eax
  801137:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113a:	8b 55 08             	mov    0x8(%ebp),%edx
  80113d:	89 c3                	mov    %eax,%ebx
  80113f:	89 c7                	mov    %eax,%edi
  801141:	89 c6                	mov    %eax,%esi
  801143:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801145:	5b                   	pop    %ebx
  801146:	5e                   	pop    %esi
  801147:	5f                   	pop    %edi
  801148:	5d                   	pop    %ebp
  801149:	c3                   	ret    

0080114a <sys_cgetc>:

int
sys_cgetc(void)
{
  80114a:	55                   	push   %ebp
  80114b:	89 e5                	mov    %esp,%ebp
  80114d:	57                   	push   %edi
  80114e:	56                   	push   %esi
  80114f:	53                   	push   %ebx
	asm volatile("int %1\n"
  801150:	ba 00 00 00 00       	mov    $0x0,%edx
  801155:	b8 01 00 00 00       	mov    $0x1,%eax
  80115a:	89 d1                	mov    %edx,%ecx
  80115c:	89 d3                	mov    %edx,%ebx
  80115e:	89 d7                	mov    %edx,%edi
  801160:	89 d6                	mov    %edx,%esi
  801162:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801164:	5b                   	pop    %ebx
  801165:	5e                   	pop    %esi
  801166:	5f                   	pop    %edi
  801167:	5d                   	pop    %ebp
  801168:	c3                   	ret    

00801169 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801169:	55                   	push   %ebp
  80116a:	89 e5                	mov    %esp,%ebp
  80116c:	57                   	push   %edi
  80116d:	56                   	push   %esi
  80116e:	53                   	push   %ebx
  80116f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801172:	b9 00 00 00 00       	mov    $0x0,%ecx
  801177:	b8 03 00 00 00       	mov    $0x3,%eax
  80117c:	8b 55 08             	mov    0x8(%ebp),%edx
  80117f:	89 cb                	mov    %ecx,%ebx
  801181:	89 cf                	mov    %ecx,%edi
  801183:	89 ce                	mov    %ecx,%esi
  801185:	cd 30                	int    $0x30
	if(check && ret > 0)
  801187:	85 c0                	test   %eax,%eax
  801189:	7e 28                	jle    8011b3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80118b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80118f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801196:	00 
  801197:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  80119e:	00 
  80119f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011a6:	00 
  8011a7:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  8011ae:	e8 43 f4 ff ff       	call   8005f6 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8011b3:	83 c4 2c             	add    $0x2c,%esp
  8011b6:	5b                   	pop    %ebx
  8011b7:	5e                   	pop    %esi
  8011b8:	5f                   	pop    %edi
  8011b9:	5d                   	pop    %ebp
  8011ba:	c3                   	ret    

008011bb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8011bb:	55                   	push   %ebp
  8011bc:	89 e5                	mov    %esp,%ebp
  8011be:	57                   	push   %edi
  8011bf:	56                   	push   %esi
  8011c0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8011c6:	b8 02 00 00 00       	mov    $0x2,%eax
  8011cb:	89 d1                	mov    %edx,%ecx
  8011cd:	89 d3                	mov    %edx,%ebx
  8011cf:	89 d7                	mov    %edx,%edi
  8011d1:	89 d6                	mov    %edx,%esi
  8011d3:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8011d5:	5b                   	pop    %ebx
  8011d6:	5e                   	pop    %esi
  8011d7:	5f                   	pop    %edi
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    

008011da <sys_yield>:

void
sys_yield(void)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	57                   	push   %edi
  8011de:	56                   	push   %esi
  8011df:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8011e5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011ea:	89 d1                	mov    %edx,%ecx
  8011ec:	89 d3                	mov    %edx,%ebx
  8011ee:	89 d7                	mov    %edx,%edi
  8011f0:	89 d6                	mov    %edx,%esi
  8011f2:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8011f4:	5b                   	pop    %ebx
  8011f5:	5e                   	pop    %esi
  8011f6:	5f                   	pop    %edi
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	57                   	push   %edi
  8011fd:	56                   	push   %esi
  8011fe:	53                   	push   %ebx
  8011ff:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801202:	be 00 00 00 00       	mov    $0x0,%esi
  801207:	b8 04 00 00 00       	mov    $0x4,%eax
  80120c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80120f:	8b 55 08             	mov    0x8(%ebp),%edx
  801212:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801215:	89 f7                	mov    %esi,%edi
  801217:	cd 30                	int    $0x30
	if(check && ret > 0)
  801219:	85 c0                	test   %eax,%eax
  80121b:	7e 28                	jle    801245 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80121d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801221:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801228:	00 
  801229:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  801230:	00 
  801231:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801238:	00 
  801239:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  801240:	e8 b1 f3 ff ff       	call   8005f6 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801245:	83 c4 2c             	add    $0x2c,%esp
  801248:	5b                   	pop    %ebx
  801249:	5e                   	pop    %esi
  80124a:	5f                   	pop    %edi
  80124b:	5d                   	pop    %ebp
  80124c:	c3                   	ret    

0080124d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80124d:	55                   	push   %ebp
  80124e:	89 e5                	mov    %esp,%ebp
  801250:	57                   	push   %edi
  801251:	56                   	push   %esi
  801252:	53                   	push   %ebx
  801253:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801256:	b8 05 00 00 00       	mov    $0x5,%eax
  80125b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80125e:	8b 55 08             	mov    0x8(%ebp),%edx
  801261:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801264:	8b 7d 14             	mov    0x14(%ebp),%edi
  801267:	8b 75 18             	mov    0x18(%ebp),%esi
  80126a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80126c:	85 c0                	test   %eax,%eax
  80126e:	7e 28                	jle    801298 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801270:	89 44 24 10          	mov    %eax,0x10(%esp)
  801274:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80127b:	00 
  80127c:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  801283:	00 
  801284:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80128b:	00 
  80128c:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  801293:	e8 5e f3 ff ff       	call   8005f6 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801298:	83 c4 2c             	add    $0x2c,%esp
  80129b:	5b                   	pop    %ebx
  80129c:	5e                   	pop    %esi
  80129d:	5f                   	pop    %edi
  80129e:	5d                   	pop    %ebp
  80129f:	c3                   	ret    

008012a0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	57                   	push   %edi
  8012a4:	56                   	push   %esi
  8012a5:	53                   	push   %ebx
  8012a6:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8012a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ae:	b8 06 00 00 00       	mov    $0x6,%eax
  8012b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b9:	89 df                	mov    %ebx,%edi
  8012bb:	89 de                	mov    %ebx,%esi
  8012bd:	cd 30                	int    $0x30
	if(check && ret > 0)
  8012bf:	85 c0                	test   %eax,%eax
  8012c1:	7e 28                	jle    8012eb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012c3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012c7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8012ce:	00 
  8012cf:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  8012d6:	00 
  8012d7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012de:	00 
  8012df:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  8012e6:	e8 0b f3 ff ff       	call   8005f6 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8012eb:	83 c4 2c             	add    $0x2c,%esp
  8012ee:	5b                   	pop    %ebx
  8012ef:	5e                   	pop    %esi
  8012f0:	5f                   	pop    %edi
  8012f1:	5d                   	pop    %ebp
  8012f2:	c3                   	ret    

008012f3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	57                   	push   %edi
  8012f7:	56                   	push   %esi
  8012f8:	53                   	push   %ebx
  8012f9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8012fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801301:	b8 08 00 00 00       	mov    $0x8,%eax
  801306:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801309:	8b 55 08             	mov    0x8(%ebp),%edx
  80130c:	89 df                	mov    %ebx,%edi
  80130e:	89 de                	mov    %ebx,%esi
  801310:	cd 30                	int    $0x30
	if(check && ret > 0)
  801312:	85 c0                	test   %eax,%eax
  801314:	7e 28                	jle    80133e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801316:	89 44 24 10          	mov    %eax,0x10(%esp)
  80131a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801321:	00 
  801322:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  801329:	00 
  80132a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801331:	00 
  801332:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  801339:	e8 b8 f2 ff ff       	call   8005f6 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80133e:	83 c4 2c             	add    $0x2c,%esp
  801341:	5b                   	pop    %ebx
  801342:	5e                   	pop    %esi
  801343:	5f                   	pop    %edi
  801344:	5d                   	pop    %ebp
  801345:	c3                   	ret    

00801346 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	57                   	push   %edi
  80134a:	56                   	push   %esi
  80134b:	53                   	push   %ebx
  80134c:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80134f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801354:	b8 09 00 00 00       	mov    $0x9,%eax
  801359:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80135c:	8b 55 08             	mov    0x8(%ebp),%edx
  80135f:	89 df                	mov    %ebx,%edi
  801361:	89 de                	mov    %ebx,%esi
  801363:	cd 30                	int    $0x30
	if(check && ret > 0)
  801365:	85 c0                	test   %eax,%eax
  801367:	7e 28                	jle    801391 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801369:	89 44 24 10          	mov    %eax,0x10(%esp)
  80136d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801374:	00 
  801375:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  80137c:	00 
  80137d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801384:	00 
  801385:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  80138c:	e8 65 f2 ff ff       	call   8005f6 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801391:	83 c4 2c             	add    $0x2c,%esp
  801394:	5b                   	pop    %ebx
  801395:	5e                   	pop    %esi
  801396:	5f                   	pop    %edi
  801397:	5d                   	pop    %ebp
  801398:	c3                   	ret    

00801399 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801399:	55                   	push   %ebp
  80139a:	89 e5                	mov    %esp,%ebp
  80139c:	57                   	push   %edi
  80139d:	56                   	push   %esi
  80139e:	53                   	push   %ebx
  80139f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8013a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013a7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8013ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013af:	8b 55 08             	mov    0x8(%ebp),%edx
  8013b2:	89 df                	mov    %ebx,%edi
  8013b4:	89 de                	mov    %ebx,%esi
  8013b6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	7e 28                	jle    8013e4 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013bc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013c0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8013c7:	00 
  8013c8:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  8013cf:	00 
  8013d0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013d7:	00 
  8013d8:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  8013df:	e8 12 f2 ff ff       	call   8005f6 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8013e4:	83 c4 2c             	add    $0x2c,%esp
  8013e7:	5b                   	pop    %ebx
  8013e8:	5e                   	pop    %esi
  8013e9:	5f                   	pop    %edi
  8013ea:	5d                   	pop    %ebp
  8013eb:	c3                   	ret    

008013ec <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	57                   	push   %edi
  8013f0:	56                   	push   %esi
  8013f1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8013f2:	be 00 00 00 00       	mov    $0x0,%esi
  8013f7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8013fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801402:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801405:	8b 7d 14             	mov    0x14(%ebp),%edi
  801408:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80140a:	5b                   	pop    %ebx
  80140b:	5e                   	pop    %esi
  80140c:	5f                   	pop    %edi
  80140d:	5d                   	pop    %ebp
  80140e:	c3                   	ret    

0080140f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80140f:	55                   	push   %ebp
  801410:	89 e5                	mov    %esp,%ebp
  801412:	57                   	push   %edi
  801413:	56                   	push   %esi
  801414:	53                   	push   %ebx
  801415:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  801418:	b9 00 00 00 00       	mov    $0x0,%ecx
  80141d:	b8 0d 00 00 00       	mov    $0xd,%eax
  801422:	8b 55 08             	mov    0x8(%ebp),%edx
  801425:	89 cb                	mov    %ecx,%ebx
  801427:	89 cf                	mov    %ecx,%edi
  801429:	89 ce                	mov    %ecx,%esi
  80142b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80142d:	85 c0                	test   %eax,%eax
  80142f:	7e 28                	jle    801459 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801431:	89 44 24 10          	mov    %eax,0x10(%esp)
  801435:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80143c:	00 
  80143d:	c7 44 24 08 bf 2a 80 	movl   $0x802abf,0x8(%esp)
  801444:	00 
  801445:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80144c:	00 
  80144d:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  801454:	e8 9d f1 ff ff       	call   8005f6 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801459:	83 c4 2c             	add    $0x2c,%esp
  80145c:	5b                   	pop    %ebx
  80145d:	5e                   	pop    %esi
  80145e:	5f                   	pop    %edi
  80145f:	5d                   	pop    %ebp
  801460:	c3                   	ret    

00801461 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801461:	55                   	push   %ebp
  801462:	89 e5                	mov    %esp,%ebp
  801464:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801467:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  80146e:	75 70                	jne    8014e0 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		//第一次要分配页面给异常stack使用
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W) < 0)
  801470:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801477:	00 
  801478:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80147f:	ee 
  801480:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801487:	e8 6d fd ff ff       	call   8011f9 <sys_page_alloc>
  80148c:	85 c0                	test   %eax,%eax
  80148e:	79 1c                	jns    8014ac <set_pgfault_handler+0x4b>
			panic("set_pgfault_handler: sys_page_alloc failed");
  801490:	c7 44 24 08 ec 2a 80 	movl   $0x802aec,0x8(%esp)
  801497:	00 
  801498:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  80149f:	00 
  8014a0:	c7 04 24 4f 2b 80 00 	movl   $0x802b4f,(%esp)
  8014a7:	e8 4a f1 ff ff       	call   8005f6 <_panic>
		//然后设置一下入口为_pgfault_upcall
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8014ac:	c7 44 24 04 ea 14 80 	movl   $0x8014ea,0x4(%esp)
  8014b3:	00 
  8014b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014bb:	e8 d9 fe ff ff       	call   801399 <sys_env_set_pgfault_upcall>
  8014c0:	85 c0                	test   %eax,%eax
  8014c2:	79 1c                	jns    8014e0 <set_pgfault_handler+0x7f>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed");
  8014c4:	c7 44 24 08 18 2b 80 	movl   $0x802b18,0x8(%esp)
  8014cb:	00 
  8014cc:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  8014d3:	00 
  8014d4:	c7 04 24 4f 2b 80 00 	movl   $0x802b4f,(%esp)
  8014db:	e8 16 f1 ff ff       	call   8005f6 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8014e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e3:	a3 b4 40 80 00       	mov    %eax,0x8040b4
}
  8014e8:	c9                   	leave  
  8014e9:	c3                   	ret    

008014ea <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8014ea:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8014eb:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  8014f0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8014f2:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax  //eip
  8014f5:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)  //原本的esp-4，用于ret
  8014f9:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx  //获得扩大后的原本的esp
  8014fe:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)      //填充ret地址
  801502:	89 03                	mov    %eax,(%ebx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801504:	83 c4 08             	add    $0x8,%esp
	popal
  801507:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801508:	83 c4 04             	add    $0x4,%esp
	popfl
  80150b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80150c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80150d:	c3                   	ret    
  80150e:	66 90                	xchg   %ax,%ax

00801510 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801513:	8b 45 08             	mov    0x8(%ebp),%eax
  801516:	05 00 00 00 30       	add    $0x30000000,%eax
  80151b:	c1 e8 0c             	shr    $0xc,%eax
}
  80151e:	5d                   	pop    %ebp
  80151f:	c3                   	ret    

00801520 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801523:	8b 45 08             	mov    0x8(%ebp),%eax
  801526:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80152b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801530:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801535:	5d                   	pop    %ebp
  801536:	c3                   	ret    

00801537 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801537:	55                   	push   %ebp
  801538:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80153a:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80153f:	a8 01                	test   $0x1,%al
  801541:	74 34                	je     801577 <fd_alloc+0x40>
  801543:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801548:	a8 01                	test   $0x1,%al
  80154a:	74 32                	je     80157e <fd_alloc+0x47>
  80154c:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
		fd = INDEX2FD(i);
  801551:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801553:	89 c2                	mov    %eax,%edx
  801555:	c1 ea 16             	shr    $0x16,%edx
  801558:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80155f:	f6 c2 01             	test   $0x1,%dl
  801562:	74 1f                	je     801583 <fd_alloc+0x4c>
  801564:	89 c2                	mov    %eax,%edx
  801566:	c1 ea 0c             	shr    $0xc,%edx
  801569:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801570:	f6 c2 01             	test   $0x1,%dl
  801573:	75 1a                	jne    80158f <fd_alloc+0x58>
  801575:	eb 0c                	jmp    801583 <fd_alloc+0x4c>
		fd = INDEX2FD(i);
  801577:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80157c:	eb 05                	jmp    801583 <fd_alloc+0x4c>
  80157e:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
			*fd_store = fd;
  801583:	8b 45 08             	mov    0x8(%ebp),%eax
  801586:	89 08                	mov    %ecx,(%eax)
			return 0;
  801588:	b8 00 00 00 00       	mov    $0x0,%eax
  80158d:	eb 1a                	jmp    8015a9 <fd_alloc+0x72>
  80158f:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801594:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801599:	75 b6                	jne    801551 <fd_alloc+0x1a>
		}
	}
	*fd_store = 0;
  80159b:	8b 45 08             	mov    0x8(%ebp),%eax
  80159e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8015a4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8015a9:	5d                   	pop    %ebp
  8015aa:	c3                   	ret    

008015ab <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8015ab:	55                   	push   %ebp
  8015ac:	89 e5                	mov    %esp,%ebp
  8015ae:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8015b1:	83 f8 1f             	cmp    $0x1f,%eax
  8015b4:	77 36                	ja     8015ec <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8015b6:	c1 e0 0c             	shl    $0xc,%eax
  8015b9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8015be:	89 c2                	mov    %eax,%edx
  8015c0:	c1 ea 16             	shr    $0x16,%edx
  8015c3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8015ca:	f6 c2 01             	test   $0x1,%dl
  8015cd:	74 24                	je     8015f3 <fd_lookup+0x48>
  8015cf:	89 c2                	mov    %eax,%edx
  8015d1:	c1 ea 0c             	shr    $0xc,%edx
  8015d4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015db:	f6 c2 01             	test   $0x1,%dl
  8015de:	74 1a                	je     8015fa <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8015e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015e3:	89 02                	mov    %eax,(%edx)
	return 0;
  8015e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ea:	eb 13                	jmp    8015ff <fd_lookup+0x54>
		return -E_INVAL;
  8015ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015f1:	eb 0c                	jmp    8015ff <fd_lookup+0x54>
		return -E_INVAL;
  8015f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015f8:	eb 05                	jmp    8015ff <fd_lookup+0x54>
  8015fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015ff:	5d                   	pop    %ebp
  801600:	c3                   	ret    

00801601 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801601:	55                   	push   %ebp
  801602:	89 e5                	mov    %esp,%ebp
  801604:	53                   	push   %ebx
  801605:	83 ec 14             	sub    $0x14,%esp
  801608:	8b 45 08             	mov    0x8(%ebp),%eax
  80160b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80160e:	39 05 04 30 80 00    	cmp    %eax,0x803004
  801614:	75 1e                	jne    801634 <dev_lookup+0x33>
  801616:	eb 0e                	jmp    801626 <dev_lookup+0x25>
	for (i = 0; devtab[i]; i++)
  801618:	b8 20 30 80 00       	mov    $0x803020,%eax
  80161d:	eb 0c                	jmp    80162b <dev_lookup+0x2a>
  80161f:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  801624:	eb 05                	jmp    80162b <dev_lookup+0x2a>
  801626:	b8 04 30 80 00       	mov    $0x803004,%eax
			*dev = devtab[i];
  80162b:	89 03                	mov    %eax,(%ebx)
			return 0;
  80162d:	b8 00 00 00 00       	mov    $0x0,%eax
  801632:	eb 38                	jmp    80166c <dev_lookup+0x6b>
		if (devtab[i]->dev_id == dev_id) {
  801634:	39 05 20 30 80 00    	cmp    %eax,0x803020
  80163a:	74 dc                	je     801618 <dev_lookup+0x17>
  80163c:	39 05 3c 30 80 00    	cmp    %eax,0x80303c
  801642:	74 db                	je     80161f <dev_lookup+0x1e>
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801644:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  80164a:	8b 52 48             	mov    0x48(%edx),%edx
  80164d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801651:	89 54 24 04          	mov    %edx,0x4(%esp)
  801655:	c7 04 24 60 2b 80 00 	movl   $0x802b60,(%esp)
  80165c:	e8 8e f0 ff ff       	call   8006ef <cprintf>
	*dev = 0;
  801661:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801667:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80166c:	83 c4 14             	add    $0x14,%esp
  80166f:	5b                   	pop    %ebx
  801670:	5d                   	pop    %ebp
  801671:	c3                   	ret    

00801672 <fd_close>:
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	56                   	push   %esi
  801676:	53                   	push   %ebx
  801677:	83 ec 20             	sub    $0x20,%esp
  80167a:	8b 75 08             	mov    0x8(%ebp),%esi
  80167d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801680:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801683:	89 44 24 04          	mov    %eax,0x4(%esp)
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801687:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80168d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801690:	89 04 24             	mov    %eax,(%esp)
  801693:	e8 13 ff ff ff       	call   8015ab <fd_lookup>
  801698:	85 c0                	test   %eax,%eax
  80169a:	78 05                	js     8016a1 <fd_close+0x2f>
	    || fd != fd2)
  80169c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80169f:	74 0c                	je     8016ad <fd_close+0x3b>
		return (must_exist ? r : 0);
  8016a1:	84 db                	test   %bl,%bl
  8016a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a8:	0f 44 c2             	cmove  %edx,%eax
  8016ab:	eb 3f                	jmp    8016ec <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8016ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b4:	8b 06                	mov    (%esi),%eax
  8016b6:	89 04 24             	mov    %eax,(%esp)
  8016b9:	e8 43 ff ff ff       	call   801601 <dev_lookup>
  8016be:	89 c3                	mov    %eax,%ebx
  8016c0:	85 c0                	test   %eax,%eax
  8016c2:	78 16                	js     8016da <fd_close+0x68>
		if (dev->dev_close)
  8016c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c7:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8016ca:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8016cf:	85 c0                	test   %eax,%eax
  8016d1:	74 07                	je     8016da <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8016d3:	89 34 24             	mov    %esi,(%esp)
  8016d6:	ff d0                	call   *%eax
  8016d8:	89 c3                	mov    %eax,%ebx
	(void) sys_page_unmap(0, fd);
  8016da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016e5:	e8 b6 fb ff ff       	call   8012a0 <sys_page_unmap>
	return r;
  8016ea:	89 d8                	mov    %ebx,%eax
}
  8016ec:	83 c4 20             	add    $0x20,%esp
  8016ef:	5b                   	pop    %ebx
  8016f0:	5e                   	pop    %esi
  8016f1:	5d                   	pop    %ebp
  8016f2:	c3                   	ret    

008016f3 <close>:

int
close(int fdnum)
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801700:	8b 45 08             	mov    0x8(%ebp),%eax
  801703:	89 04 24             	mov    %eax,(%esp)
  801706:	e8 a0 fe ff ff       	call   8015ab <fd_lookup>
  80170b:	89 c2                	mov    %eax,%edx
  80170d:	85 d2                	test   %edx,%edx
  80170f:	78 13                	js     801724 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801711:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801718:	00 
  801719:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171c:	89 04 24             	mov    %eax,(%esp)
  80171f:	e8 4e ff ff ff       	call   801672 <fd_close>
}
  801724:	c9                   	leave  
  801725:	c3                   	ret    

00801726 <close_all>:

void
close_all(void)
{
  801726:	55                   	push   %ebp
  801727:	89 e5                	mov    %esp,%ebp
  801729:	53                   	push   %ebx
  80172a:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80172d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801732:	89 1c 24             	mov    %ebx,(%esp)
  801735:	e8 b9 ff ff ff       	call   8016f3 <close>
	for (i = 0; i < MAXFD; i++)
  80173a:	83 c3 01             	add    $0x1,%ebx
  80173d:	83 fb 20             	cmp    $0x20,%ebx
  801740:	75 f0                	jne    801732 <close_all+0xc>
}
  801742:	83 c4 14             	add    $0x14,%esp
  801745:	5b                   	pop    %ebx
  801746:	5d                   	pop    %ebp
  801747:	c3                   	ret    

00801748 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801748:	55                   	push   %ebp
  801749:	89 e5                	mov    %esp,%ebp
  80174b:	57                   	push   %edi
  80174c:	56                   	push   %esi
  80174d:	53                   	push   %ebx
  80174e:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801751:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801754:	89 44 24 04          	mov    %eax,0x4(%esp)
  801758:	8b 45 08             	mov    0x8(%ebp),%eax
  80175b:	89 04 24             	mov    %eax,(%esp)
  80175e:	e8 48 fe ff ff       	call   8015ab <fd_lookup>
  801763:	89 c2                	mov    %eax,%edx
  801765:	85 d2                	test   %edx,%edx
  801767:	0f 88 e1 00 00 00    	js     80184e <dup+0x106>
		return r;
	close(newfdnum);
  80176d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801770:	89 04 24             	mov    %eax,(%esp)
  801773:	e8 7b ff ff ff       	call   8016f3 <close>

	newfd = INDEX2FD(newfdnum);
  801778:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80177b:	c1 e3 0c             	shl    $0xc,%ebx
  80177e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801784:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801787:	89 04 24             	mov    %eax,(%esp)
  80178a:	e8 91 fd ff ff       	call   801520 <fd2data>
  80178f:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801791:	89 1c 24             	mov    %ebx,(%esp)
  801794:	e8 87 fd ff ff       	call   801520 <fd2data>
  801799:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80179b:	89 f0                	mov    %esi,%eax
  80179d:	c1 e8 16             	shr    $0x16,%eax
  8017a0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8017a7:	a8 01                	test   $0x1,%al
  8017a9:	74 43                	je     8017ee <dup+0xa6>
  8017ab:	89 f0                	mov    %esi,%eax
  8017ad:	c1 e8 0c             	shr    $0xc,%eax
  8017b0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8017b7:	f6 c2 01             	test   $0x1,%dl
  8017ba:	74 32                	je     8017ee <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8017bc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017c3:	25 07 0e 00 00       	and    $0xe07,%eax
  8017c8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017cc:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8017d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017d7:	00 
  8017d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017e3:	e8 65 fa ff ff       	call   80124d <sys_page_map>
  8017e8:	89 c6                	mov    %eax,%esi
  8017ea:	85 c0                	test   %eax,%eax
  8017ec:	78 3e                	js     80182c <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017f1:	89 c2                	mov    %eax,%edx
  8017f3:	c1 ea 0c             	shr    $0xc,%edx
  8017f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017fd:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801803:	89 54 24 10          	mov    %edx,0x10(%esp)
  801807:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80180b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801812:	00 
  801813:	89 44 24 04          	mov    %eax,0x4(%esp)
  801817:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80181e:	e8 2a fa ff ff       	call   80124d <sys_page_map>
  801823:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801825:	8b 45 0c             	mov    0xc(%ebp),%eax
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801828:	85 f6                	test   %esi,%esi
  80182a:	79 22                	jns    80184e <dup+0x106>

err:
	sys_page_unmap(0, newfd);
  80182c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801830:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801837:	e8 64 fa ff ff       	call   8012a0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80183c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801840:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801847:	e8 54 fa ff ff       	call   8012a0 <sys_page_unmap>
	return r;
  80184c:	89 f0                	mov    %esi,%eax
}
  80184e:	83 c4 3c             	add    $0x3c,%esp
  801851:	5b                   	pop    %ebx
  801852:	5e                   	pop    %esi
  801853:	5f                   	pop    %edi
  801854:	5d                   	pop    %ebp
  801855:	c3                   	ret    

00801856 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801856:	55                   	push   %ebp
  801857:	89 e5                	mov    %esp,%ebp
  801859:	53                   	push   %ebx
  80185a:	83 ec 24             	sub    $0x24,%esp
  80185d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801860:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801863:	89 44 24 04          	mov    %eax,0x4(%esp)
  801867:	89 1c 24             	mov    %ebx,(%esp)
  80186a:	e8 3c fd ff ff       	call   8015ab <fd_lookup>
  80186f:	89 c2                	mov    %eax,%edx
  801871:	85 d2                	test   %edx,%edx
  801873:	78 6d                	js     8018e2 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801875:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801878:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80187f:	8b 00                	mov    (%eax),%eax
  801881:	89 04 24             	mov    %eax,(%esp)
  801884:	e8 78 fd ff ff       	call   801601 <dev_lookup>
  801889:	85 c0                	test   %eax,%eax
  80188b:	78 55                	js     8018e2 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80188d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801890:	8b 50 08             	mov    0x8(%eax),%edx
  801893:	83 e2 03             	and    $0x3,%edx
  801896:	83 fa 01             	cmp    $0x1,%edx
  801899:	75 23                	jne    8018be <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80189b:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8018a0:	8b 40 48             	mov    0x48(%eax),%eax
  8018a3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ab:	c7 04 24 a4 2b 80 00 	movl   $0x802ba4,(%esp)
  8018b2:	e8 38 ee ff ff       	call   8006ef <cprintf>
		return -E_INVAL;
  8018b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018bc:	eb 24                	jmp    8018e2 <read+0x8c>
	}
	if (!dev->dev_read)
  8018be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c1:	8b 52 08             	mov    0x8(%edx),%edx
  8018c4:	85 d2                	test   %edx,%edx
  8018c6:	74 15                	je     8018dd <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8018c8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018cb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018d2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018d6:	89 04 24             	mov    %eax,(%esp)
  8018d9:	ff d2                	call   *%edx
  8018db:	eb 05                	jmp    8018e2 <read+0x8c>
		return -E_NOT_SUPP;
  8018dd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8018e2:	83 c4 24             	add    $0x24,%esp
  8018e5:	5b                   	pop    %ebx
  8018e6:	5d                   	pop    %ebp
  8018e7:	c3                   	ret    

008018e8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	57                   	push   %edi
  8018ec:	56                   	push   %esi
  8018ed:	53                   	push   %ebx
  8018ee:	83 ec 1c             	sub    $0x1c,%esp
  8018f1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018f4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018f7:	85 f6                	test   %esi,%esi
  8018f9:	74 33                	je     80192e <readn+0x46>
  8018fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801900:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801905:	89 f2                	mov    %esi,%edx
  801907:	29 c2                	sub    %eax,%edx
  801909:	89 54 24 08          	mov    %edx,0x8(%esp)
  80190d:	03 45 0c             	add    0xc(%ebp),%eax
  801910:	89 44 24 04          	mov    %eax,0x4(%esp)
  801914:	89 3c 24             	mov    %edi,(%esp)
  801917:	e8 3a ff ff ff       	call   801856 <read>
		if (m < 0)
  80191c:	85 c0                	test   %eax,%eax
  80191e:	78 1b                	js     80193b <readn+0x53>
			return m;
		if (m == 0)
  801920:	85 c0                	test   %eax,%eax
  801922:	74 11                	je     801935 <readn+0x4d>
	for (tot = 0; tot < n; tot += m) {
  801924:	01 c3                	add    %eax,%ebx
  801926:	89 d8                	mov    %ebx,%eax
  801928:	39 f3                	cmp    %esi,%ebx
  80192a:	72 d9                	jb     801905 <readn+0x1d>
  80192c:	eb 0b                	jmp    801939 <readn+0x51>
  80192e:	b8 00 00 00 00       	mov    $0x0,%eax
  801933:	eb 06                	jmp    80193b <readn+0x53>
  801935:	89 d8                	mov    %ebx,%eax
  801937:	eb 02                	jmp    80193b <readn+0x53>
  801939:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80193b:	83 c4 1c             	add    $0x1c,%esp
  80193e:	5b                   	pop    %ebx
  80193f:	5e                   	pop    %esi
  801940:	5f                   	pop    %edi
  801941:	5d                   	pop    %ebp
  801942:	c3                   	ret    

00801943 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	53                   	push   %ebx
  801947:	83 ec 24             	sub    $0x24,%esp
  80194a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80194d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801950:	89 44 24 04          	mov    %eax,0x4(%esp)
  801954:	89 1c 24             	mov    %ebx,(%esp)
  801957:	e8 4f fc ff ff       	call   8015ab <fd_lookup>
  80195c:	89 c2                	mov    %eax,%edx
  80195e:	85 d2                	test   %edx,%edx
  801960:	78 68                	js     8019ca <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801962:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801965:	89 44 24 04          	mov    %eax,0x4(%esp)
  801969:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80196c:	8b 00                	mov    (%eax),%eax
  80196e:	89 04 24             	mov    %eax,(%esp)
  801971:	e8 8b fc ff ff       	call   801601 <dev_lookup>
  801976:	85 c0                	test   %eax,%eax
  801978:	78 50                	js     8019ca <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80197a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80197d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801981:	75 23                	jne    8019a6 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801983:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801988:	8b 40 48             	mov    0x48(%eax),%eax
  80198b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80198f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801993:	c7 04 24 c0 2b 80 00 	movl   $0x802bc0,(%esp)
  80199a:	e8 50 ed ff ff       	call   8006ef <cprintf>
		return -E_INVAL;
  80199f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019a4:	eb 24                	jmp    8019ca <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8019a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019a9:	8b 52 0c             	mov    0xc(%edx),%edx
  8019ac:	85 d2                	test   %edx,%edx
  8019ae:	74 15                	je     8019c5 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8019b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8019b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8019b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019ba:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019be:	89 04 24             	mov    %eax,(%esp)
  8019c1:	ff d2                	call   *%edx
  8019c3:	eb 05                	jmp    8019ca <write+0x87>
		return -E_NOT_SUPP;
  8019c5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  8019ca:	83 c4 24             	add    $0x24,%esp
  8019cd:	5b                   	pop    %ebx
  8019ce:	5d                   	pop    %ebp
  8019cf:	c3                   	ret    

008019d0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019d6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8019d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e0:	89 04 24             	mov    %eax,(%esp)
  8019e3:	e8 c3 fb ff ff       	call   8015ab <fd_lookup>
  8019e8:	85 c0                	test   %eax,%eax
  8019ea:	78 0e                	js     8019fa <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8019ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8019ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019f2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8019f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019fa:	c9                   	leave  
  8019fb:	c3                   	ret    

008019fc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	53                   	push   %ebx
  801a00:	83 ec 24             	sub    $0x24,%esp
  801a03:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a06:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a09:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0d:	89 1c 24             	mov    %ebx,(%esp)
  801a10:	e8 96 fb ff ff       	call   8015ab <fd_lookup>
  801a15:	89 c2                	mov    %eax,%edx
  801a17:	85 d2                	test   %edx,%edx
  801a19:	78 61                	js     801a7c <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a25:	8b 00                	mov    (%eax),%eax
  801a27:	89 04 24             	mov    %eax,(%esp)
  801a2a:	e8 d2 fb ff ff       	call   801601 <dev_lookup>
  801a2f:	85 c0                	test   %eax,%eax
  801a31:	78 49                	js     801a7c <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a36:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a3a:	75 23                	jne    801a5f <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801a3c:	a1 b0 40 80 00       	mov    0x8040b0,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801a41:	8b 40 48             	mov    0x48(%eax),%eax
  801a44:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a48:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4c:	c7 04 24 80 2b 80 00 	movl   $0x802b80,(%esp)
  801a53:	e8 97 ec ff ff       	call   8006ef <cprintf>
		return -E_INVAL;
  801a58:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a5d:	eb 1d                	jmp    801a7c <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801a5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a62:	8b 52 18             	mov    0x18(%edx),%edx
  801a65:	85 d2                	test   %edx,%edx
  801a67:	74 0e                	je     801a77 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801a69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a6c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a70:	89 04 24             	mov    %eax,(%esp)
  801a73:	ff d2                	call   *%edx
  801a75:	eb 05                	jmp    801a7c <ftruncate+0x80>
		return -E_NOT_SUPP;
  801a77:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801a7c:	83 c4 24             	add    $0x24,%esp
  801a7f:	5b                   	pop    %ebx
  801a80:	5d                   	pop    %ebp
  801a81:	c3                   	ret    

00801a82 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	53                   	push   %ebx
  801a86:	83 ec 24             	sub    $0x24,%esp
  801a89:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a8c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a93:	8b 45 08             	mov    0x8(%ebp),%eax
  801a96:	89 04 24             	mov    %eax,(%esp)
  801a99:	e8 0d fb ff ff       	call   8015ab <fd_lookup>
  801a9e:	89 c2                	mov    %eax,%edx
  801aa0:	85 d2                	test   %edx,%edx
  801aa2:	78 52                	js     801af6 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801aa4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aae:	8b 00                	mov    (%eax),%eax
  801ab0:	89 04 24             	mov    %eax,(%esp)
  801ab3:	e8 49 fb ff ff       	call   801601 <dev_lookup>
  801ab8:	85 c0                	test   %eax,%eax
  801aba:	78 3a                	js     801af6 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801abf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801ac3:	74 2c                	je     801af1 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801ac5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801ac8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801acf:	00 00 00 
	stat->st_isdir = 0;
  801ad2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ad9:	00 00 00 
	stat->st_dev = dev;
  801adc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801ae2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ae6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ae9:	89 14 24             	mov    %edx,(%esp)
  801aec:	ff 50 14             	call   *0x14(%eax)
  801aef:	eb 05                	jmp    801af6 <fstat+0x74>
		return -E_NOT_SUPP;
  801af1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
}
  801af6:	83 c4 24             	add    $0x24,%esp
  801af9:	5b                   	pop    %ebx
  801afa:	5d                   	pop    %ebp
  801afb:	c3                   	ret    

00801afc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	56                   	push   %esi
  801b00:	53                   	push   %ebx
  801b01:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801b04:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b0b:	00 
  801b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0f:	89 04 24             	mov    %eax,(%esp)
  801b12:	e8 af 01 00 00       	call   801cc6 <open>
  801b17:	89 c3                	mov    %eax,%ebx
  801b19:	85 db                	test   %ebx,%ebx
  801b1b:	78 1b                	js     801b38 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801b1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b20:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b24:	89 1c 24             	mov    %ebx,(%esp)
  801b27:	e8 56 ff ff ff       	call   801a82 <fstat>
  801b2c:	89 c6                	mov    %eax,%esi
	close(fd);
  801b2e:	89 1c 24             	mov    %ebx,(%esp)
  801b31:	e8 bd fb ff ff       	call   8016f3 <close>
	return r;
  801b36:	89 f0                	mov    %esi,%eax
}
  801b38:	83 c4 10             	add    $0x10,%esp
  801b3b:	5b                   	pop    %ebx
  801b3c:	5e                   	pop    %esi
  801b3d:	5d                   	pop    %ebp
  801b3e:	c3                   	ret    

00801b3f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801b3f:	55                   	push   %ebp
  801b40:	89 e5                	mov    %esp,%ebp
  801b42:	56                   	push   %esi
  801b43:	53                   	push   %ebx
  801b44:	83 ec 10             	sub    $0x10,%esp
  801b47:	89 c6                	mov    %eax,%esi
  801b49:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801b4b:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  801b52:	75 11                	jne    801b65 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b54:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801b5b:	e8 fa 07 00 00       	call   80235a <ipc_find_env>
  801b60:	a3 ac 40 80 00       	mov    %eax,0x8040ac
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b65:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b6c:	00 
  801b6d:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801b74:	00 
  801b75:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b79:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  801b7e:	89 04 24             	mov    %eax,(%esp)
  801b81:	e8 8c 07 00 00       	call   802312 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801b86:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b8d:	00 
  801b8e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b92:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b99:	e8 18 07 00 00       	call   8022b6 <ipc_recv>
}
  801b9e:	83 c4 10             	add    $0x10,%esp
  801ba1:	5b                   	pop    %ebx
  801ba2:	5e                   	pop    %esi
  801ba3:	5d                   	pop    %ebp
  801ba4:	c3                   	ret    

00801ba5 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	53                   	push   %ebx
  801ba9:	83 ec 14             	sub    $0x14,%esp
  801bac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801baf:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb2:	8b 40 0c             	mov    0xc(%eax),%eax
  801bb5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801bba:	ba 00 00 00 00       	mov    $0x0,%edx
  801bbf:	b8 05 00 00 00       	mov    $0x5,%eax
  801bc4:	e8 76 ff ff ff       	call   801b3f <fsipc>
  801bc9:	89 c2                	mov    %eax,%edx
  801bcb:	85 d2                	test   %edx,%edx
  801bcd:	78 2b                	js     801bfa <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801bcf:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801bd6:	00 
  801bd7:	89 1c 24             	mov    %ebx,(%esp)
  801bda:	e8 6c f1 ff ff       	call   800d4b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801bdf:	a1 80 50 80 00       	mov    0x805080,%eax
  801be4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801bea:	a1 84 50 80 00       	mov    0x805084,%eax
  801bef:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801bf5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bfa:	83 c4 14             	add    $0x14,%esp
  801bfd:	5b                   	pop    %ebx
  801bfe:	5d                   	pop    %ebp
  801bff:	c3                   	ret    

00801c00 <devfile_flush>:
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c06:	8b 45 08             	mov    0x8(%ebp),%eax
  801c09:	8b 40 0c             	mov    0xc(%eax),%eax
  801c0c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801c11:	ba 00 00 00 00       	mov    $0x0,%edx
  801c16:	b8 06 00 00 00       	mov    $0x6,%eax
  801c1b:	e8 1f ff ff ff       	call   801b3f <fsipc>
}
  801c20:	c9                   	leave  
  801c21:	c3                   	ret    

00801c22 <devfile_read>:
{
  801c22:	55                   	push   %ebp
  801c23:	89 e5                	mov    %esp,%ebp
  801c25:	56                   	push   %esi
  801c26:	53                   	push   %ebx
  801c27:	83 ec 10             	sub    $0x10,%esp
  801c2a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c30:	8b 40 0c             	mov    0xc(%eax),%eax
  801c33:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801c38:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c3e:	ba 00 00 00 00       	mov    $0x0,%edx
  801c43:	b8 03 00 00 00       	mov    $0x3,%eax
  801c48:	e8 f2 fe ff ff       	call   801b3f <fsipc>
  801c4d:	89 c3                	mov    %eax,%ebx
  801c4f:	85 c0                	test   %eax,%eax
  801c51:	78 6a                	js     801cbd <devfile_read+0x9b>
	assert(r <= n);
  801c53:	39 c6                	cmp    %eax,%esi
  801c55:	73 24                	jae    801c7b <devfile_read+0x59>
  801c57:	c7 44 24 0c dd 2b 80 	movl   $0x802bdd,0xc(%esp)
  801c5e:	00 
  801c5f:	c7 44 24 08 e4 2b 80 	movl   $0x802be4,0x8(%esp)
  801c66:	00 
  801c67:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  801c6e:	00 
  801c6f:	c7 04 24 f9 2b 80 00 	movl   $0x802bf9,(%esp)
  801c76:	e8 7b e9 ff ff       	call   8005f6 <_panic>
	assert(r <= PGSIZE);
  801c7b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c80:	7e 24                	jle    801ca6 <devfile_read+0x84>
  801c82:	c7 44 24 0c 04 2c 80 	movl   $0x802c04,0xc(%esp)
  801c89:	00 
  801c8a:	c7 44 24 08 e4 2b 80 	movl   $0x802be4,0x8(%esp)
  801c91:	00 
  801c92:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801c99:	00 
  801c9a:	c7 04 24 f9 2b 80 00 	movl   $0x802bf9,(%esp)
  801ca1:	e8 50 e9 ff ff       	call   8005f6 <_panic>
	memmove(buf, &fsipcbuf, r);
  801ca6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801caa:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801cb1:	00 
  801cb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb5:	89 04 24             	mov    %eax,(%esp)
  801cb8:	e8 89 f2 ff ff       	call   800f46 <memmove>
}
  801cbd:	89 d8                	mov    %ebx,%eax
  801cbf:	83 c4 10             	add    $0x10,%esp
  801cc2:	5b                   	pop    %ebx
  801cc3:	5e                   	pop    %esi
  801cc4:	5d                   	pop    %ebp
  801cc5:	c3                   	ret    

00801cc6 <open>:
{
  801cc6:	55                   	push   %ebp
  801cc7:	89 e5                	mov    %esp,%ebp
  801cc9:	53                   	push   %ebx
  801cca:	83 ec 24             	sub    $0x24,%esp
  801ccd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801cd0:	89 1c 24             	mov    %ebx,(%esp)
  801cd3:	e8 18 f0 ff ff       	call   800cf0 <strlen>
  801cd8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801cdd:	7f 60                	jg     801d3f <open+0x79>
	if ((r = fd_alloc(&fd)) < 0)
  801cdf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce2:	89 04 24             	mov    %eax,(%esp)
  801ce5:	e8 4d f8 ff ff       	call   801537 <fd_alloc>
  801cea:	89 c2                	mov    %eax,%edx
  801cec:	85 d2                	test   %edx,%edx
  801cee:	78 54                	js     801d44 <open+0x7e>
	strcpy(fsipcbuf.open.req_path, path);
  801cf0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cf4:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801cfb:	e8 4b f0 ff ff       	call   800d4b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801d00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d03:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801d08:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d0b:	b8 01 00 00 00       	mov    $0x1,%eax
  801d10:	e8 2a fe ff ff       	call   801b3f <fsipc>
  801d15:	89 c3                	mov    %eax,%ebx
  801d17:	85 c0                	test   %eax,%eax
  801d19:	79 17                	jns    801d32 <open+0x6c>
		fd_close(fd, 0);
  801d1b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d22:	00 
  801d23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d26:	89 04 24             	mov    %eax,(%esp)
  801d29:	e8 44 f9 ff ff       	call   801672 <fd_close>
		return r;
  801d2e:	89 d8                	mov    %ebx,%eax
  801d30:	eb 12                	jmp    801d44 <open+0x7e>
	return fd2num(fd);
  801d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d35:	89 04 24             	mov    %eax,(%esp)
  801d38:	e8 d3 f7 ff ff       	call   801510 <fd2num>
  801d3d:	eb 05                	jmp    801d44 <open+0x7e>
		return -E_BAD_PATH;
  801d3f:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
}
  801d44:	83 c4 24             	add    $0x24,%esp
  801d47:	5b                   	pop    %ebx
  801d48:	5d                   	pop    %ebp
  801d49:	c3                   	ret    
  801d4a:	66 90                	xchg   %ax,%ax
  801d4c:	66 90                	xchg   %ax,%ax
  801d4e:	66 90                	xchg   %ax,%ax

00801d50 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	56                   	push   %esi
  801d54:	53                   	push   %ebx
  801d55:	83 ec 10             	sub    $0x10,%esp
  801d58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5e:	89 04 24             	mov    %eax,(%esp)
  801d61:	e8 ba f7 ff ff       	call   801520 <fd2data>
  801d66:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d68:	c7 44 24 04 10 2c 80 	movl   $0x802c10,0x4(%esp)
  801d6f:	00 
  801d70:	89 1c 24             	mov    %ebx,(%esp)
  801d73:	e8 d3 ef ff ff       	call   800d4b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d78:	8b 46 04             	mov    0x4(%esi),%eax
  801d7b:	2b 06                	sub    (%esi),%eax
  801d7d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d83:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d8a:	00 00 00 
	stat->st_dev = &devpipe;
  801d8d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801d94:	30 80 00 
	return 0;
}
  801d97:	b8 00 00 00 00       	mov    $0x0,%eax
  801d9c:	83 c4 10             	add    $0x10,%esp
  801d9f:	5b                   	pop    %ebx
  801da0:	5e                   	pop    %esi
  801da1:	5d                   	pop    %ebp
  801da2:	c3                   	ret    

00801da3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	53                   	push   %ebx
  801da7:	83 ec 14             	sub    $0x14,%esp
  801daa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801dad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801db1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801db8:	e8 e3 f4 ff ff       	call   8012a0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801dbd:	89 1c 24             	mov    %ebx,(%esp)
  801dc0:	e8 5b f7 ff ff       	call   801520 <fd2data>
  801dc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dc9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dd0:	e8 cb f4 ff ff       	call   8012a0 <sys_page_unmap>
}
  801dd5:	83 c4 14             	add    $0x14,%esp
  801dd8:	5b                   	pop    %ebx
  801dd9:	5d                   	pop    %ebp
  801dda:	c3                   	ret    

00801ddb <_pipeisclosed>:
{
  801ddb:	55                   	push   %ebp
  801ddc:	89 e5                	mov    %esp,%ebp
  801dde:	57                   	push   %edi
  801ddf:	56                   	push   %esi
  801de0:	53                   	push   %ebx
  801de1:	83 ec 2c             	sub    $0x2c,%esp
  801de4:	89 c6                	mov    %eax,%esi
  801de6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		n = thisenv->env_runs;
  801de9:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801dee:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801df1:	89 34 24             	mov    %esi,(%esp)
  801df4:	e8 a9 05 00 00       	call   8023a2 <pageref>
  801df9:	89 c7                	mov    %eax,%edi
  801dfb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dfe:	89 04 24             	mov    %eax,(%esp)
  801e01:	e8 9c 05 00 00       	call   8023a2 <pageref>
  801e06:	39 c7                	cmp    %eax,%edi
  801e08:	0f 94 c2             	sete   %dl
  801e0b:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  801e0e:	8b 0d b0 40 80 00    	mov    0x8040b0,%ecx
  801e14:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801e17:	39 fb                	cmp    %edi,%ebx
  801e19:	74 21                	je     801e3c <_pipeisclosed+0x61>
		if (n != nn && ret == 1)
  801e1b:	84 d2                	test   %dl,%dl
  801e1d:	74 ca                	je     801de9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e1f:	8b 51 58             	mov    0x58(%ecx),%edx
  801e22:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e26:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e2a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e2e:	c7 04 24 17 2c 80 00 	movl   $0x802c17,(%esp)
  801e35:	e8 b5 e8 ff ff       	call   8006ef <cprintf>
  801e3a:	eb ad                	jmp    801de9 <_pipeisclosed+0xe>
}
  801e3c:	83 c4 2c             	add    $0x2c,%esp
  801e3f:	5b                   	pop    %ebx
  801e40:	5e                   	pop    %esi
  801e41:	5f                   	pop    %edi
  801e42:	5d                   	pop    %ebp
  801e43:	c3                   	ret    

00801e44 <devpipe_write>:
{
  801e44:	55                   	push   %ebp
  801e45:	89 e5                	mov    %esp,%ebp
  801e47:	57                   	push   %edi
  801e48:	56                   	push   %esi
  801e49:	53                   	push   %ebx
  801e4a:	83 ec 1c             	sub    $0x1c,%esp
  801e4d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801e50:	89 34 24             	mov    %esi,(%esp)
  801e53:	e8 c8 f6 ff ff       	call   801520 <fd2data>
	for (i = 0; i < n; i++) {
  801e58:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e5c:	74 61                	je     801ebf <devpipe_write+0x7b>
  801e5e:	89 c3                	mov    %eax,%ebx
  801e60:	bf 00 00 00 00       	mov    $0x0,%edi
  801e65:	eb 4a                	jmp    801eb1 <devpipe_write+0x6d>
			if (_pipeisclosed(fd, p))
  801e67:	89 da                	mov    %ebx,%edx
  801e69:	89 f0                	mov    %esi,%eax
  801e6b:	e8 6b ff ff ff       	call   801ddb <_pipeisclosed>
  801e70:	85 c0                	test   %eax,%eax
  801e72:	75 54                	jne    801ec8 <devpipe_write+0x84>
			sys_yield();
  801e74:	e8 61 f3 ff ff       	call   8011da <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e79:	8b 43 04             	mov    0x4(%ebx),%eax
  801e7c:	8b 0b                	mov    (%ebx),%ecx
  801e7e:	8d 51 20             	lea    0x20(%ecx),%edx
  801e81:	39 d0                	cmp    %edx,%eax
  801e83:	73 e2                	jae    801e67 <devpipe_write+0x23>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e88:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e8c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e8f:	99                   	cltd   
  801e90:	c1 ea 1b             	shr    $0x1b,%edx
  801e93:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801e96:	83 e1 1f             	and    $0x1f,%ecx
  801e99:	29 d1                	sub    %edx,%ecx
  801e9b:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801e9f:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801ea3:	83 c0 01             	add    $0x1,%eax
  801ea6:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801ea9:	83 c7 01             	add    $0x1,%edi
  801eac:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801eaf:	74 13                	je     801ec4 <devpipe_write+0x80>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801eb1:	8b 43 04             	mov    0x4(%ebx),%eax
  801eb4:	8b 0b                	mov    (%ebx),%ecx
  801eb6:	8d 51 20             	lea    0x20(%ecx),%edx
  801eb9:	39 d0                	cmp    %edx,%eax
  801ebb:	73 aa                	jae    801e67 <devpipe_write+0x23>
  801ebd:	eb c6                	jmp    801e85 <devpipe_write+0x41>
	for (i = 0; i < n; i++) {
  801ebf:	bf 00 00 00 00       	mov    $0x0,%edi
	return i;
  801ec4:	89 f8                	mov    %edi,%eax
  801ec6:	eb 05                	jmp    801ecd <devpipe_write+0x89>
				return 0;
  801ec8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ecd:	83 c4 1c             	add    $0x1c,%esp
  801ed0:	5b                   	pop    %ebx
  801ed1:	5e                   	pop    %esi
  801ed2:	5f                   	pop    %edi
  801ed3:	5d                   	pop    %ebp
  801ed4:	c3                   	ret    

00801ed5 <devpipe_read>:
{
  801ed5:	55                   	push   %ebp
  801ed6:	89 e5                	mov    %esp,%ebp
  801ed8:	57                   	push   %edi
  801ed9:	56                   	push   %esi
  801eda:	53                   	push   %ebx
  801edb:	83 ec 1c             	sub    $0x1c,%esp
  801ede:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801ee1:	89 3c 24             	mov    %edi,(%esp)
  801ee4:	e8 37 f6 ff ff       	call   801520 <fd2data>
	for (i = 0; i < n; i++) {
  801ee9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801eed:	74 54                	je     801f43 <devpipe_read+0x6e>
  801eef:	89 c3                	mov    %eax,%ebx
  801ef1:	be 00 00 00 00       	mov    $0x0,%esi
  801ef6:	eb 3e                	jmp    801f36 <devpipe_read+0x61>
				return i;
  801ef8:	89 f0                	mov    %esi,%eax
  801efa:	eb 55                	jmp    801f51 <devpipe_read+0x7c>
			if (_pipeisclosed(fd, p))
  801efc:	89 da                	mov    %ebx,%edx
  801efe:	89 f8                	mov    %edi,%eax
  801f00:	e8 d6 fe ff ff       	call   801ddb <_pipeisclosed>
  801f05:	85 c0                	test   %eax,%eax
  801f07:	75 43                	jne    801f4c <devpipe_read+0x77>
			sys_yield();
  801f09:	e8 cc f2 ff ff       	call   8011da <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801f0e:	8b 03                	mov    (%ebx),%eax
  801f10:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f13:	74 e7                	je     801efc <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f15:	99                   	cltd   
  801f16:	c1 ea 1b             	shr    $0x1b,%edx
  801f19:	01 d0                	add    %edx,%eax
  801f1b:	83 e0 1f             	and    $0x1f,%eax
  801f1e:	29 d0                	sub    %edx,%eax
  801f20:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801f25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f28:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801f2b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801f2e:	83 c6 01             	add    $0x1,%esi
  801f31:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f34:	74 12                	je     801f48 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
  801f36:	8b 03                	mov    (%ebx),%eax
  801f38:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f3b:	75 d8                	jne    801f15 <devpipe_read+0x40>
			if (i > 0)
  801f3d:	85 f6                	test   %esi,%esi
  801f3f:	75 b7                	jne    801ef8 <devpipe_read+0x23>
  801f41:	eb b9                	jmp    801efc <devpipe_read+0x27>
	for (i = 0; i < n; i++) {
  801f43:	be 00 00 00 00       	mov    $0x0,%esi
	return i;
  801f48:	89 f0                	mov    %esi,%eax
  801f4a:	eb 05                	jmp    801f51 <devpipe_read+0x7c>
				return 0;
  801f4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f51:	83 c4 1c             	add    $0x1c,%esp
  801f54:	5b                   	pop    %ebx
  801f55:	5e                   	pop    %esi
  801f56:	5f                   	pop    %edi
  801f57:	5d                   	pop    %ebp
  801f58:	c3                   	ret    

00801f59 <pipe>:
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
  801f5c:	56                   	push   %esi
  801f5d:	53                   	push   %ebx
  801f5e:	83 ec 30             	sub    $0x30,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801f61:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f64:	89 04 24             	mov    %eax,(%esp)
  801f67:	e8 cb f5 ff ff       	call   801537 <fd_alloc>
  801f6c:	89 c2                	mov    %eax,%edx
  801f6e:	85 d2                	test   %edx,%edx
  801f70:	0f 88 4d 01 00 00    	js     8020c3 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f76:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f7d:	00 
  801f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f81:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f8c:	e8 68 f2 ff ff       	call   8011f9 <sys_page_alloc>
  801f91:	89 c2                	mov    %eax,%edx
  801f93:	85 d2                	test   %edx,%edx
  801f95:	0f 88 28 01 00 00    	js     8020c3 <pipe+0x16a>
	if ((r = fd_alloc(&fd1)) < 0
  801f9b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f9e:	89 04 24             	mov    %eax,(%esp)
  801fa1:	e8 91 f5 ff ff       	call   801537 <fd_alloc>
  801fa6:	89 c3                	mov    %eax,%ebx
  801fa8:	85 c0                	test   %eax,%eax
  801faa:	0f 88 fe 00 00 00    	js     8020ae <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fb0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fb7:	00 
  801fb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fbf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fc6:	e8 2e f2 ff ff       	call   8011f9 <sys_page_alloc>
  801fcb:	89 c3                	mov    %eax,%ebx
  801fcd:	85 c0                	test   %eax,%eax
  801fcf:	0f 88 d9 00 00 00    	js     8020ae <pipe+0x155>
	va = fd2data(fd0);
  801fd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd8:	89 04 24             	mov    %eax,(%esp)
  801fdb:	e8 40 f5 ff ff       	call   801520 <fd2data>
  801fe0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fe2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fe9:	00 
  801fea:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ff5:	e8 ff f1 ff ff       	call   8011f9 <sys_page_alloc>
  801ffa:	89 c3                	mov    %eax,%ebx
  801ffc:	85 c0                	test   %eax,%eax
  801ffe:	0f 88 97 00 00 00    	js     80209b <pipe+0x142>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802004:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802007:	89 04 24             	mov    %eax,(%esp)
  80200a:	e8 11 f5 ff ff       	call   801520 <fd2data>
  80200f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802016:	00 
  802017:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80201b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802022:	00 
  802023:	89 74 24 04          	mov    %esi,0x4(%esp)
  802027:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80202e:	e8 1a f2 ff ff       	call   80124d <sys_page_map>
  802033:	89 c3                	mov    %eax,%ebx
  802035:	85 c0                	test   %eax,%eax
  802037:	78 52                	js     80208b <pipe+0x132>
	fd0->fd_dev_id = devpipe.dev_id;
  802039:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80203f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802042:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802044:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802047:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  80204e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802054:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802057:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802059:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80205c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802063:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802066:	89 04 24             	mov    %eax,(%esp)
  802069:	e8 a2 f4 ff ff       	call   801510 <fd2num>
  80206e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802071:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802073:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802076:	89 04 24             	mov    %eax,(%esp)
  802079:	e8 92 f4 ff ff       	call   801510 <fd2num>
  80207e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802081:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802084:	b8 00 00 00 00       	mov    $0x0,%eax
  802089:	eb 38                	jmp    8020c3 <pipe+0x16a>
	sys_page_unmap(0, va);
  80208b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80208f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802096:	e8 05 f2 ff ff       	call   8012a0 <sys_page_unmap>
	sys_page_unmap(0, fd1);
  80209b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80209e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020a9:	e8 f2 f1 ff ff       	call   8012a0 <sys_page_unmap>
	sys_page_unmap(0, fd0);
  8020ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020bc:	e8 df f1 ff ff       	call   8012a0 <sys_page_unmap>
  8020c1:	89 d8                	mov    %ebx,%eax
}
  8020c3:	83 c4 30             	add    $0x30,%esp
  8020c6:	5b                   	pop    %ebx
  8020c7:	5e                   	pop    %esi
  8020c8:	5d                   	pop    %ebp
  8020c9:	c3                   	ret    

008020ca <pipeisclosed>:
{
  8020ca:	55                   	push   %ebp
  8020cb:	89 e5                	mov    %esp,%ebp
  8020cd:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8020da:	89 04 24             	mov    %eax,(%esp)
  8020dd:	e8 c9 f4 ff ff       	call   8015ab <fd_lookup>
  8020e2:	89 c2                	mov    %eax,%edx
  8020e4:	85 d2                	test   %edx,%edx
  8020e6:	78 15                	js     8020fd <pipeisclosed+0x33>
	p = (struct Pipe*) fd2data(fd);
  8020e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020eb:	89 04 24             	mov    %eax,(%esp)
  8020ee:	e8 2d f4 ff ff       	call   801520 <fd2data>
	return _pipeisclosed(fd, p);
  8020f3:	89 c2                	mov    %eax,%edx
  8020f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f8:	e8 de fc ff ff       	call   801ddb <_pipeisclosed>
}
  8020fd:	c9                   	leave  
  8020fe:	c3                   	ret    
  8020ff:	90                   	nop

00802100 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802100:	55                   	push   %ebp
  802101:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802103:	b8 00 00 00 00       	mov    $0x0,%eax
  802108:	5d                   	pop    %ebp
  802109:	c3                   	ret    

0080210a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80210a:	55                   	push   %ebp
  80210b:	89 e5                	mov    %esp,%ebp
  80210d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802110:	c7 44 24 04 2f 2c 80 	movl   $0x802c2f,0x4(%esp)
  802117:	00 
  802118:	8b 45 0c             	mov    0xc(%ebp),%eax
  80211b:	89 04 24             	mov    %eax,(%esp)
  80211e:	e8 28 ec ff ff       	call   800d4b <strcpy>
	return 0;
}
  802123:	b8 00 00 00 00       	mov    $0x0,%eax
  802128:	c9                   	leave  
  802129:	c3                   	ret    

0080212a <devcons_write>:
{
  80212a:	55                   	push   %ebp
  80212b:	89 e5                	mov    %esp,%ebp
  80212d:	57                   	push   %edi
  80212e:	56                   	push   %esi
  80212f:	53                   	push   %ebx
  802130:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	for (tot = 0; tot < n; tot += m) {
  802136:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80213a:	74 4a                	je     802186 <devcons_write+0x5c>
  80213c:	b8 00 00 00 00       	mov    $0x0,%eax
  802141:	bb 00 00 00 00       	mov    $0x0,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802146:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
		m = n - tot;
  80214c:	8b 75 10             	mov    0x10(%ebp),%esi
  80214f:	29 c6                	sub    %eax,%esi
		if (m > sizeof(buf) - 1)
  802151:	83 fe 7f             	cmp    $0x7f,%esi
		m = n - tot;
  802154:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802159:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80215c:	89 74 24 08          	mov    %esi,0x8(%esp)
  802160:	03 45 0c             	add    0xc(%ebp),%eax
  802163:	89 44 24 04          	mov    %eax,0x4(%esp)
  802167:	89 3c 24             	mov    %edi,(%esp)
  80216a:	e8 d7 ed ff ff       	call   800f46 <memmove>
		sys_cputs(buf, m);
  80216f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802173:	89 3c 24             	mov    %edi,(%esp)
  802176:	e8 b1 ef ff ff       	call   80112c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80217b:	01 f3                	add    %esi,%ebx
  80217d:	89 d8                	mov    %ebx,%eax
  80217f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802182:	72 c8                	jb     80214c <devcons_write+0x22>
  802184:	eb 05                	jmp    80218b <devcons_write+0x61>
  802186:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  80218b:	89 d8                	mov    %ebx,%eax
  80218d:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802193:	5b                   	pop    %ebx
  802194:	5e                   	pop    %esi
  802195:	5f                   	pop    %edi
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    

00802198 <devcons_read>:
{
  802198:	55                   	push   %ebp
  802199:	89 e5                	mov    %esp,%ebp
  80219b:	83 ec 08             	sub    $0x8,%esp
		return 0;
  80219e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8021a3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021a7:	75 07                	jne    8021b0 <devcons_read+0x18>
  8021a9:	eb 28                	jmp    8021d3 <devcons_read+0x3b>
		sys_yield();
  8021ab:	e8 2a f0 ff ff       	call   8011da <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8021b0:	e8 95 ef ff ff       	call   80114a <sys_cgetc>
  8021b5:	85 c0                	test   %eax,%eax
  8021b7:	74 f2                	je     8021ab <devcons_read+0x13>
	if (c < 0)
  8021b9:	85 c0                	test   %eax,%eax
  8021bb:	78 16                	js     8021d3 <devcons_read+0x3b>
	if (c == 0x04)	// ctl-d is eof
  8021bd:	83 f8 04             	cmp    $0x4,%eax
  8021c0:	74 0c                	je     8021ce <devcons_read+0x36>
	*(char*)vbuf = c;
  8021c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021c5:	88 02                	mov    %al,(%edx)
	return 1;
  8021c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8021cc:	eb 05                	jmp    8021d3 <devcons_read+0x3b>
		return 0;
  8021ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021d3:	c9                   	leave  
  8021d4:	c3                   	ret    

008021d5 <cputchar>:
{
  8021d5:	55                   	push   %ebp
  8021d6:	89 e5                	mov    %esp,%ebp
  8021d8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8021db:	8b 45 08             	mov    0x8(%ebp),%eax
  8021de:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8021e1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8021e8:	00 
  8021e9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021ec:	89 04 24             	mov    %eax,(%esp)
  8021ef:	e8 38 ef ff ff       	call   80112c <sys_cputs>
}
  8021f4:	c9                   	leave  
  8021f5:	c3                   	ret    

008021f6 <getchar>:
{
  8021f6:	55                   	push   %ebp
  8021f7:	89 e5                	mov    %esp,%ebp
  8021f9:	83 ec 28             	sub    $0x28,%esp
	r = read(0, &c, 1);
  8021fc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802203:	00 
  802204:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802207:	89 44 24 04          	mov    %eax,0x4(%esp)
  80220b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802212:	e8 3f f6 ff ff       	call   801856 <read>
	if (r < 0)
  802217:	85 c0                	test   %eax,%eax
  802219:	78 0f                	js     80222a <getchar+0x34>
	if (r < 1)
  80221b:	85 c0                	test   %eax,%eax
  80221d:	7e 06                	jle    802225 <getchar+0x2f>
	return c;
  80221f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802223:	eb 05                	jmp    80222a <getchar+0x34>
		return -E_EOF;
  802225:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
}
  80222a:	c9                   	leave  
  80222b:	c3                   	ret    

0080222c <iscons>:
{
  80222c:	55                   	push   %ebp
  80222d:	89 e5                	mov    %esp,%ebp
  80222f:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802232:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802235:	89 44 24 04          	mov    %eax,0x4(%esp)
  802239:	8b 45 08             	mov    0x8(%ebp),%eax
  80223c:	89 04 24             	mov    %eax,(%esp)
  80223f:	e8 67 f3 ff ff       	call   8015ab <fd_lookup>
  802244:	85 c0                	test   %eax,%eax
  802246:	78 11                	js     802259 <iscons+0x2d>
	return fd->fd_dev_id == devcons.dev_id;
  802248:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80224b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802251:	39 10                	cmp    %edx,(%eax)
  802253:	0f 94 c0             	sete   %al
  802256:	0f b6 c0             	movzbl %al,%eax
}
  802259:	c9                   	leave  
  80225a:	c3                   	ret    

0080225b <opencons>:
{
  80225b:	55                   	push   %ebp
  80225c:	89 e5                	mov    %esp,%ebp
  80225e:	83 ec 28             	sub    $0x28,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802261:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802264:	89 04 24             	mov    %eax,(%esp)
  802267:	e8 cb f2 ff ff       	call   801537 <fd_alloc>
		return r;
  80226c:	89 c2                	mov    %eax,%edx
	if ((r = fd_alloc(&fd)) < 0)
  80226e:	85 c0                	test   %eax,%eax
  802270:	78 40                	js     8022b2 <opencons+0x57>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802272:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802279:	00 
  80227a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80227d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802281:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802288:	e8 6c ef ff ff       	call   8011f9 <sys_page_alloc>
		return r;
  80228d:	89 c2                	mov    %eax,%edx
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80228f:	85 c0                	test   %eax,%eax
  802291:	78 1f                	js     8022b2 <opencons+0x57>
	fd->fd_dev_id = devcons.dev_id;
  802293:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802299:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80229c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80229e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022a1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022a8:	89 04 24             	mov    %eax,(%esp)
  8022ab:	e8 60 f2 ff ff       	call   801510 <fd2num>
  8022b0:	89 c2                	mov    %eax,%edx
}
  8022b2:	89 d0                	mov    %edx,%eax
  8022b4:	c9                   	leave  
  8022b5:	c3                   	ret    

008022b6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022b6:	55                   	push   %ebp
  8022b7:	89 e5                	mov    %esp,%ebp
  8022b9:	56                   	push   %esi
  8022ba:	53                   	push   %ebx
  8022bb:	83 ec 10             	sub    $0x10,%esp
  8022be:	8b 75 08             	mov    0x8(%ebp),%esi
  8022c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int result = sys_ipc_recv(pg);
  8022c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022c7:	89 04 24             	mov    %eax,(%esp)
  8022ca:	e8 40 f1 ff ff       	call   80140f <sys_ipc_recv>
	if(from_env_store)
  8022cf:	85 f6                	test   %esi,%esi
  8022d1:	74 14                	je     8022e7 <ipc_recv+0x31>
		*from_env_store = (result<0?0:thisenv->env_ipc_from);
  8022d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8022d8:	85 c0                	test   %eax,%eax
  8022da:	78 09                	js     8022e5 <ipc_recv+0x2f>
  8022dc:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  8022e2:	8b 52 74             	mov    0x74(%edx),%edx
  8022e5:	89 16                	mov    %edx,(%esi)
	if(perm_store)
  8022e7:	85 db                	test   %ebx,%ebx
  8022e9:	74 14                	je     8022ff <ipc_recv+0x49>
		*perm_store = (result<0?0:thisenv->env_ipc_perm);
  8022eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8022f0:	85 c0                	test   %eax,%eax
  8022f2:	78 09                	js     8022fd <ipc_recv+0x47>
  8022f4:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  8022fa:	8b 52 78             	mov    0x78(%edx),%edx
  8022fd:	89 13                	mov    %edx,(%ebx)
	if(result < 0)
  8022ff:	85 c0                	test   %eax,%eax
  802301:	78 08                	js     80230b <ipc_recv+0x55>
		return result;
	return thisenv->env_ipc_value;
  802303:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802308:	8b 40 70             	mov    0x70(%eax),%eax
}
  80230b:	83 c4 10             	add    $0x10,%esp
  80230e:	5b                   	pop    %ebx
  80230f:	5e                   	pop    %esi
  802310:	5d                   	pop    %ebp
  802311:	c3                   	ret    

00802312 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802312:	55                   	push   %ebp
  802313:	89 e5                	mov    %esp,%ebp
  802315:	57                   	push   %edi
  802316:	56                   	push   %esi
  802317:	53                   	push   %ebx
  802318:	83 ec 1c             	sub    $0x1c,%esp
  80231b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80231e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	unsigned failed_cnt = 0;
  802321:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  802326:	eb 0c                	jmp    802334 <ipc_send+0x22>
		failed_cnt++;
  802328:	83 c3 01             	add    $0x1,%ebx
		if(!(failed_cnt & 0xff))
  80232b:	84 db                	test   %bl,%bl
  80232d:	75 05                	jne    802334 <ipc_send+0x22>
			//失败到一定次数后放弃CPU
			sys_yield();
  80232f:	e8 a6 ee ff ff       	call   8011da <sys_yield>
	while(sys_ipc_try_send(to_env, val, pg, perm) < 0){
  802334:	8b 45 14             	mov    0x14(%ebp),%eax
  802337:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80233b:	8b 45 10             	mov    0x10(%ebp),%eax
  80233e:	89 44 24 08          	mov    %eax,0x8(%esp)
  802342:	89 74 24 04          	mov    %esi,0x4(%esp)
  802346:	89 3c 24             	mov    %edi,(%esp)
  802349:	e8 9e f0 ff ff       	call   8013ec <sys_ipc_try_send>
  80234e:	85 c0                	test   %eax,%eax
  802350:	78 d6                	js     802328 <ipc_send+0x16>
	}
}
  802352:	83 c4 1c             	add    $0x1c,%esp
  802355:	5b                   	pop    %ebx
  802356:	5e                   	pop    %esi
  802357:	5f                   	pop    %edi
  802358:	5d                   	pop    %ebp
  802359:	c3                   	ret    

0080235a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80235a:	55                   	push   %ebp
  80235b:	89 e5                	mov    %esp,%ebp
  80235d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802360:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  802365:	39 c8                	cmp    %ecx,%eax
  802367:	74 17                	je     802380 <ipc_find_env+0x26>
	for (i = 0; i < NENV; i++)
  802369:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80236e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802371:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802377:	8b 52 50             	mov    0x50(%edx),%edx
  80237a:	39 ca                	cmp    %ecx,%edx
  80237c:	75 14                	jne    802392 <ipc_find_env+0x38>
  80237e:	eb 05                	jmp    802385 <ipc_find_env+0x2b>
	for (i = 0; i < NENV; i++)
  802380:	b8 00 00 00 00       	mov    $0x0,%eax
			return envs[i].env_id;
  802385:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802388:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80238d:	8b 40 40             	mov    0x40(%eax),%eax
  802390:	eb 0e                	jmp    8023a0 <ipc_find_env+0x46>
	for (i = 0; i < NENV; i++)
  802392:	83 c0 01             	add    $0x1,%eax
  802395:	3d 00 04 00 00       	cmp    $0x400,%eax
  80239a:	75 d2                	jne    80236e <ipc_find_env+0x14>
	return 0;
  80239c:	66 b8 00 00          	mov    $0x0,%ax
}
  8023a0:	5d                   	pop    %ebp
  8023a1:	c3                   	ret    

008023a2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023a2:	55                   	push   %ebp
  8023a3:	89 e5                	mov    %esp,%ebp
  8023a5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023a8:	89 d0                	mov    %edx,%eax
  8023aa:	c1 e8 16             	shr    $0x16,%eax
  8023ad:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023b4:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  8023b9:	f6 c1 01             	test   $0x1,%cl
  8023bc:	74 1d                	je     8023db <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  8023be:	c1 ea 0c             	shr    $0xc,%edx
  8023c1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023c8:	f6 c2 01             	test   $0x1,%dl
  8023cb:	74 0e                	je     8023db <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023cd:	c1 ea 0c             	shr    $0xc,%edx
  8023d0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023d7:	ef 
  8023d8:	0f b7 c0             	movzwl %ax,%eax
}
  8023db:	5d                   	pop    %ebp
  8023dc:	c3                   	ret    
  8023dd:	66 90                	xchg   %ax,%ax
  8023df:	90                   	nop

008023e0 <__udivdi3>:
  8023e0:	55                   	push   %ebp
  8023e1:	57                   	push   %edi
  8023e2:	56                   	push   %esi
  8023e3:	83 ec 0c             	sub    $0xc,%esp
  8023e6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8023ea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8023ee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8023f2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8023f6:	85 c0                	test   %eax,%eax
  8023f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8023fc:	89 ea                	mov    %ebp,%edx
  8023fe:	89 0c 24             	mov    %ecx,(%esp)
  802401:	75 2d                	jne    802430 <__udivdi3+0x50>
  802403:	39 e9                	cmp    %ebp,%ecx
  802405:	77 61                	ja     802468 <__udivdi3+0x88>
  802407:	85 c9                	test   %ecx,%ecx
  802409:	89 ce                	mov    %ecx,%esi
  80240b:	75 0b                	jne    802418 <__udivdi3+0x38>
  80240d:	b8 01 00 00 00       	mov    $0x1,%eax
  802412:	31 d2                	xor    %edx,%edx
  802414:	f7 f1                	div    %ecx
  802416:	89 c6                	mov    %eax,%esi
  802418:	31 d2                	xor    %edx,%edx
  80241a:	89 e8                	mov    %ebp,%eax
  80241c:	f7 f6                	div    %esi
  80241e:	89 c5                	mov    %eax,%ebp
  802420:	89 f8                	mov    %edi,%eax
  802422:	f7 f6                	div    %esi
  802424:	89 ea                	mov    %ebp,%edx
  802426:	83 c4 0c             	add    $0xc,%esp
  802429:	5e                   	pop    %esi
  80242a:	5f                   	pop    %edi
  80242b:	5d                   	pop    %ebp
  80242c:	c3                   	ret    
  80242d:	8d 76 00             	lea    0x0(%esi),%esi
  802430:	39 e8                	cmp    %ebp,%eax
  802432:	77 24                	ja     802458 <__udivdi3+0x78>
  802434:	0f bd e8             	bsr    %eax,%ebp
  802437:	83 f5 1f             	xor    $0x1f,%ebp
  80243a:	75 3c                	jne    802478 <__udivdi3+0x98>
  80243c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802440:	39 34 24             	cmp    %esi,(%esp)
  802443:	0f 86 9f 00 00 00    	jbe    8024e8 <__udivdi3+0x108>
  802449:	39 d0                	cmp    %edx,%eax
  80244b:	0f 82 97 00 00 00    	jb     8024e8 <__udivdi3+0x108>
  802451:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802458:	31 d2                	xor    %edx,%edx
  80245a:	31 c0                	xor    %eax,%eax
  80245c:	83 c4 0c             	add    $0xc,%esp
  80245f:	5e                   	pop    %esi
  802460:	5f                   	pop    %edi
  802461:	5d                   	pop    %ebp
  802462:	c3                   	ret    
  802463:	90                   	nop
  802464:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802468:	89 f8                	mov    %edi,%eax
  80246a:	f7 f1                	div    %ecx
  80246c:	31 d2                	xor    %edx,%edx
  80246e:	83 c4 0c             	add    $0xc,%esp
  802471:	5e                   	pop    %esi
  802472:	5f                   	pop    %edi
  802473:	5d                   	pop    %ebp
  802474:	c3                   	ret    
  802475:	8d 76 00             	lea    0x0(%esi),%esi
  802478:	89 e9                	mov    %ebp,%ecx
  80247a:	8b 3c 24             	mov    (%esp),%edi
  80247d:	d3 e0                	shl    %cl,%eax
  80247f:	89 c6                	mov    %eax,%esi
  802481:	b8 20 00 00 00       	mov    $0x20,%eax
  802486:	29 e8                	sub    %ebp,%eax
  802488:	89 c1                	mov    %eax,%ecx
  80248a:	d3 ef                	shr    %cl,%edi
  80248c:	89 e9                	mov    %ebp,%ecx
  80248e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802492:	8b 3c 24             	mov    (%esp),%edi
  802495:	09 74 24 08          	or     %esi,0x8(%esp)
  802499:	89 d6                	mov    %edx,%esi
  80249b:	d3 e7                	shl    %cl,%edi
  80249d:	89 c1                	mov    %eax,%ecx
  80249f:	89 3c 24             	mov    %edi,(%esp)
  8024a2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024a6:	d3 ee                	shr    %cl,%esi
  8024a8:	89 e9                	mov    %ebp,%ecx
  8024aa:	d3 e2                	shl    %cl,%edx
  8024ac:	89 c1                	mov    %eax,%ecx
  8024ae:	d3 ef                	shr    %cl,%edi
  8024b0:	09 d7                	or     %edx,%edi
  8024b2:	89 f2                	mov    %esi,%edx
  8024b4:	89 f8                	mov    %edi,%eax
  8024b6:	f7 74 24 08          	divl   0x8(%esp)
  8024ba:	89 d6                	mov    %edx,%esi
  8024bc:	89 c7                	mov    %eax,%edi
  8024be:	f7 24 24             	mull   (%esp)
  8024c1:	39 d6                	cmp    %edx,%esi
  8024c3:	89 14 24             	mov    %edx,(%esp)
  8024c6:	72 30                	jb     8024f8 <__udivdi3+0x118>
  8024c8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024cc:	89 e9                	mov    %ebp,%ecx
  8024ce:	d3 e2                	shl    %cl,%edx
  8024d0:	39 c2                	cmp    %eax,%edx
  8024d2:	73 05                	jae    8024d9 <__udivdi3+0xf9>
  8024d4:	3b 34 24             	cmp    (%esp),%esi
  8024d7:	74 1f                	je     8024f8 <__udivdi3+0x118>
  8024d9:	89 f8                	mov    %edi,%eax
  8024db:	31 d2                	xor    %edx,%edx
  8024dd:	e9 7a ff ff ff       	jmp    80245c <__udivdi3+0x7c>
  8024e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024e8:	31 d2                	xor    %edx,%edx
  8024ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8024ef:	e9 68 ff ff ff       	jmp    80245c <__udivdi3+0x7c>
  8024f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024f8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8024fb:	31 d2                	xor    %edx,%edx
  8024fd:	83 c4 0c             	add    $0xc,%esp
  802500:	5e                   	pop    %esi
  802501:	5f                   	pop    %edi
  802502:	5d                   	pop    %ebp
  802503:	c3                   	ret    
  802504:	66 90                	xchg   %ax,%ax
  802506:	66 90                	xchg   %ax,%ax
  802508:	66 90                	xchg   %ax,%ax
  80250a:	66 90                	xchg   %ax,%ax
  80250c:	66 90                	xchg   %ax,%ax
  80250e:	66 90                	xchg   %ax,%ax

00802510 <__umoddi3>:
  802510:	55                   	push   %ebp
  802511:	57                   	push   %edi
  802512:	56                   	push   %esi
  802513:	83 ec 14             	sub    $0x14,%esp
  802516:	8b 44 24 28          	mov    0x28(%esp),%eax
  80251a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80251e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802522:	89 c7                	mov    %eax,%edi
  802524:	89 44 24 04          	mov    %eax,0x4(%esp)
  802528:	8b 44 24 30          	mov    0x30(%esp),%eax
  80252c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802530:	89 34 24             	mov    %esi,(%esp)
  802533:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802537:	85 c0                	test   %eax,%eax
  802539:	89 c2                	mov    %eax,%edx
  80253b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80253f:	75 17                	jne    802558 <__umoddi3+0x48>
  802541:	39 fe                	cmp    %edi,%esi
  802543:	76 4b                	jbe    802590 <__umoddi3+0x80>
  802545:	89 c8                	mov    %ecx,%eax
  802547:	89 fa                	mov    %edi,%edx
  802549:	f7 f6                	div    %esi
  80254b:	89 d0                	mov    %edx,%eax
  80254d:	31 d2                	xor    %edx,%edx
  80254f:	83 c4 14             	add    $0x14,%esp
  802552:	5e                   	pop    %esi
  802553:	5f                   	pop    %edi
  802554:	5d                   	pop    %ebp
  802555:	c3                   	ret    
  802556:	66 90                	xchg   %ax,%ax
  802558:	39 f8                	cmp    %edi,%eax
  80255a:	77 54                	ja     8025b0 <__umoddi3+0xa0>
  80255c:	0f bd e8             	bsr    %eax,%ebp
  80255f:	83 f5 1f             	xor    $0x1f,%ebp
  802562:	75 5c                	jne    8025c0 <__umoddi3+0xb0>
  802564:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802568:	39 3c 24             	cmp    %edi,(%esp)
  80256b:	0f 87 e7 00 00 00    	ja     802658 <__umoddi3+0x148>
  802571:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802575:	29 f1                	sub    %esi,%ecx
  802577:	19 c7                	sbb    %eax,%edi
  802579:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80257d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802581:	8b 44 24 08          	mov    0x8(%esp),%eax
  802585:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802589:	83 c4 14             	add    $0x14,%esp
  80258c:	5e                   	pop    %esi
  80258d:	5f                   	pop    %edi
  80258e:	5d                   	pop    %ebp
  80258f:	c3                   	ret    
  802590:	85 f6                	test   %esi,%esi
  802592:	89 f5                	mov    %esi,%ebp
  802594:	75 0b                	jne    8025a1 <__umoddi3+0x91>
  802596:	b8 01 00 00 00       	mov    $0x1,%eax
  80259b:	31 d2                	xor    %edx,%edx
  80259d:	f7 f6                	div    %esi
  80259f:	89 c5                	mov    %eax,%ebp
  8025a1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8025a5:	31 d2                	xor    %edx,%edx
  8025a7:	f7 f5                	div    %ebp
  8025a9:	89 c8                	mov    %ecx,%eax
  8025ab:	f7 f5                	div    %ebp
  8025ad:	eb 9c                	jmp    80254b <__umoddi3+0x3b>
  8025af:	90                   	nop
  8025b0:	89 c8                	mov    %ecx,%eax
  8025b2:	89 fa                	mov    %edi,%edx
  8025b4:	83 c4 14             	add    $0x14,%esp
  8025b7:	5e                   	pop    %esi
  8025b8:	5f                   	pop    %edi
  8025b9:	5d                   	pop    %ebp
  8025ba:	c3                   	ret    
  8025bb:	90                   	nop
  8025bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025c0:	8b 04 24             	mov    (%esp),%eax
  8025c3:	be 20 00 00 00       	mov    $0x20,%esi
  8025c8:	89 e9                	mov    %ebp,%ecx
  8025ca:	29 ee                	sub    %ebp,%esi
  8025cc:	d3 e2                	shl    %cl,%edx
  8025ce:	89 f1                	mov    %esi,%ecx
  8025d0:	d3 e8                	shr    %cl,%eax
  8025d2:	89 e9                	mov    %ebp,%ecx
  8025d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025d8:	8b 04 24             	mov    (%esp),%eax
  8025db:	09 54 24 04          	or     %edx,0x4(%esp)
  8025df:	89 fa                	mov    %edi,%edx
  8025e1:	d3 e0                	shl    %cl,%eax
  8025e3:	89 f1                	mov    %esi,%ecx
  8025e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025e9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8025ed:	d3 ea                	shr    %cl,%edx
  8025ef:	89 e9                	mov    %ebp,%ecx
  8025f1:	d3 e7                	shl    %cl,%edi
  8025f3:	89 f1                	mov    %esi,%ecx
  8025f5:	d3 e8                	shr    %cl,%eax
  8025f7:	89 e9                	mov    %ebp,%ecx
  8025f9:	09 f8                	or     %edi,%eax
  8025fb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8025ff:	f7 74 24 04          	divl   0x4(%esp)
  802603:	d3 e7                	shl    %cl,%edi
  802605:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802609:	89 d7                	mov    %edx,%edi
  80260b:	f7 64 24 08          	mull   0x8(%esp)
  80260f:	39 d7                	cmp    %edx,%edi
  802611:	89 c1                	mov    %eax,%ecx
  802613:	89 14 24             	mov    %edx,(%esp)
  802616:	72 2c                	jb     802644 <__umoddi3+0x134>
  802618:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80261c:	72 22                	jb     802640 <__umoddi3+0x130>
  80261e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802622:	29 c8                	sub    %ecx,%eax
  802624:	19 d7                	sbb    %edx,%edi
  802626:	89 e9                	mov    %ebp,%ecx
  802628:	89 fa                	mov    %edi,%edx
  80262a:	d3 e8                	shr    %cl,%eax
  80262c:	89 f1                	mov    %esi,%ecx
  80262e:	d3 e2                	shl    %cl,%edx
  802630:	89 e9                	mov    %ebp,%ecx
  802632:	d3 ef                	shr    %cl,%edi
  802634:	09 d0                	or     %edx,%eax
  802636:	89 fa                	mov    %edi,%edx
  802638:	83 c4 14             	add    $0x14,%esp
  80263b:	5e                   	pop    %esi
  80263c:	5f                   	pop    %edi
  80263d:	5d                   	pop    %ebp
  80263e:	c3                   	ret    
  80263f:	90                   	nop
  802640:	39 d7                	cmp    %edx,%edi
  802642:	75 da                	jne    80261e <__umoddi3+0x10e>
  802644:	8b 14 24             	mov    (%esp),%edx
  802647:	89 c1                	mov    %eax,%ecx
  802649:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80264d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  802651:	eb cb                	jmp    80261e <__umoddi3+0x10e>
  802653:	90                   	nop
  802654:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802658:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80265c:	0f 82 0f ff ff ff    	jb     802571 <__umoddi3+0x61>
  802662:	e9 1a ff ff ff       	jmp    802581 <__umoddi3+0x71>
