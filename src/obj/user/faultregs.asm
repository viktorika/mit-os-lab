
obj/user/faultregs：     文件格式 elf32-i386


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
  80004b:	c7 44 24 04 91 17 80 	movl   $0x801791,0x4(%esp)
  800052:	00 
  800053:	c7 04 24 60 17 80 00 	movl   $0x801760,(%esp)
  80005a:	e8 8b 06 00 00       	call   8006ea <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  80005f:	8b 03                	mov    (%ebx),%eax
  800061:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800065:	8b 06                	mov    (%esi),%eax
  800067:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006b:	c7 44 24 04 70 17 80 	movl   $0x801770,0x4(%esp)
  800072:	00 
  800073:	c7 04 24 74 17 80 00 	movl   $0x801774,(%esp)
  80007a:	e8 6b 06 00 00       	call   8006ea <cprintf>
  80007f:	8b 03                	mov    (%ebx),%eax
  800081:	39 06                	cmp    %eax,(%esi)
  800083:	75 13                	jne    800098 <check_regs+0x65>
  800085:	c7 04 24 84 17 80 00 	movl   $0x801784,(%esp)
  80008c:	e8 59 06 00 00       	call   8006ea <cprintf>
	int mismatch = 0;
  800091:	bf 00 00 00 00       	mov    $0x0,%edi
  800096:	eb 11                	jmp    8000a9 <check_regs+0x76>
	CHECK(edi, regs.reg_edi);
  800098:	c7 04 24 88 17 80 00 	movl   $0x801788,(%esp)
  80009f:	e8 46 06 00 00       	call   8006ea <cprintf>
  8000a4:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000a9:	8b 43 04             	mov    0x4(%ebx),%eax
  8000ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b0:	8b 46 04             	mov    0x4(%esi),%eax
  8000b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b7:	c7 44 24 04 92 17 80 	movl   $0x801792,0x4(%esp)
  8000be:	00 
  8000bf:	c7 04 24 74 17 80 00 	movl   $0x801774,(%esp)
  8000c6:	e8 1f 06 00 00       	call   8006ea <cprintf>
  8000cb:	8b 43 04             	mov    0x4(%ebx),%eax
  8000ce:	39 46 04             	cmp    %eax,0x4(%esi)
  8000d1:	75 0e                	jne    8000e1 <check_regs+0xae>
  8000d3:	c7 04 24 84 17 80 00 	movl   $0x801784,(%esp)
  8000da:	e8 0b 06 00 00       	call   8006ea <cprintf>
  8000df:	eb 11                	jmp    8000f2 <check_regs+0xbf>
  8000e1:	c7 04 24 88 17 80 00 	movl   $0x801788,(%esp)
  8000e8:	e8 fd 05 00 00       	call   8006ea <cprintf>
  8000ed:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000f2:	8b 43 08             	mov    0x8(%ebx),%eax
  8000f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f9:	8b 46 08             	mov    0x8(%esi),%eax
  8000fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800100:	c7 44 24 04 96 17 80 	movl   $0x801796,0x4(%esp)
  800107:	00 
  800108:	c7 04 24 74 17 80 00 	movl   $0x801774,(%esp)
  80010f:	e8 d6 05 00 00       	call   8006ea <cprintf>
  800114:	8b 43 08             	mov    0x8(%ebx),%eax
  800117:	39 46 08             	cmp    %eax,0x8(%esi)
  80011a:	75 0e                	jne    80012a <check_regs+0xf7>
  80011c:	c7 04 24 84 17 80 00 	movl   $0x801784,(%esp)
  800123:	e8 c2 05 00 00       	call   8006ea <cprintf>
  800128:	eb 11                	jmp    80013b <check_regs+0x108>
  80012a:	c7 04 24 88 17 80 00 	movl   $0x801788,(%esp)
  800131:	e8 b4 05 00 00       	call   8006ea <cprintf>
  800136:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80013b:	8b 43 10             	mov    0x10(%ebx),%eax
  80013e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800142:	8b 46 10             	mov    0x10(%esi),%eax
  800145:	89 44 24 08          	mov    %eax,0x8(%esp)
  800149:	c7 44 24 04 9a 17 80 	movl   $0x80179a,0x4(%esp)
  800150:	00 
  800151:	c7 04 24 74 17 80 00 	movl   $0x801774,(%esp)
  800158:	e8 8d 05 00 00       	call   8006ea <cprintf>
  80015d:	8b 43 10             	mov    0x10(%ebx),%eax
  800160:	39 46 10             	cmp    %eax,0x10(%esi)
  800163:	75 0e                	jne    800173 <check_regs+0x140>
  800165:	c7 04 24 84 17 80 00 	movl   $0x801784,(%esp)
  80016c:	e8 79 05 00 00       	call   8006ea <cprintf>
  800171:	eb 11                	jmp    800184 <check_regs+0x151>
  800173:	c7 04 24 88 17 80 00 	movl   $0x801788,(%esp)
  80017a:	e8 6b 05 00 00       	call   8006ea <cprintf>
  80017f:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800184:	8b 43 14             	mov    0x14(%ebx),%eax
  800187:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018b:	8b 46 14             	mov    0x14(%esi),%eax
  80018e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800192:	c7 44 24 04 9e 17 80 	movl   $0x80179e,0x4(%esp)
  800199:	00 
  80019a:	c7 04 24 74 17 80 00 	movl   $0x801774,(%esp)
  8001a1:	e8 44 05 00 00       	call   8006ea <cprintf>
  8001a6:	8b 43 14             	mov    0x14(%ebx),%eax
  8001a9:	39 46 14             	cmp    %eax,0x14(%esi)
  8001ac:	75 0e                	jne    8001bc <check_regs+0x189>
  8001ae:	c7 04 24 84 17 80 00 	movl   $0x801784,(%esp)
  8001b5:	e8 30 05 00 00       	call   8006ea <cprintf>
  8001ba:	eb 11                	jmp    8001cd <check_regs+0x19a>
  8001bc:	c7 04 24 88 17 80 00 	movl   $0x801788,(%esp)
  8001c3:	e8 22 05 00 00       	call   8006ea <cprintf>
  8001c8:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001cd:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d4:	8b 46 18             	mov    0x18(%esi),%eax
  8001d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001db:	c7 44 24 04 a2 17 80 	movl   $0x8017a2,0x4(%esp)
  8001e2:	00 
  8001e3:	c7 04 24 74 17 80 00 	movl   $0x801774,(%esp)
  8001ea:	e8 fb 04 00 00       	call   8006ea <cprintf>
  8001ef:	8b 43 18             	mov    0x18(%ebx),%eax
  8001f2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001f5:	75 0e                	jne    800205 <check_regs+0x1d2>
  8001f7:	c7 04 24 84 17 80 00 	movl   $0x801784,(%esp)
  8001fe:	e8 e7 04 00 00       	call   8006ea <cprintf>
  800203:	eb 11                	jmp    800216 <check_regs+0x1e3>
  800205:	c7 04 24 88 17 80 00 	movl   $0x801788,(%esp)
  80020c:	e8 d9 04 00 00       	call   8006ea <cprintf>
  800211:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021d:	8b 46 1c             	mov    0x1c(%esi),%eax
  800220:	89 44 24 08          	mov    %eax,0x8(%esp)
  800224:	c7 44 24 04 a6 17 80 	movl   $0x8017a6,0x4(%esp)
  80022b:	00 
  80022c:	c7 04 24 74 17 80 00 	movl   $0x801774,(%esp)
  800233:	e8 b2 04 00 00       	call   8006ea <cprintf>
  800238:	8b 43 1c             	mov    0x1c(%ebx),%eax
  80023b:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80023e:	75 0e                	jne    80024e <check_regs+0x21b>
  800240:	c7 04 24 84 17 80 00 	movl   $0x801784,(%esp)
  800247:	e8 9e 04 00 00       	call   8006ea <cprintf>
  80024c:	eb 11                	jmp    80025f <check_regs+0x22c>
  80024e:	c7 04 24 88 17 80 00 	movl   $0x801788,(%esp)
  800255:	e8 90 04 00 00       	call   8006ea <cprintf>
  80025a:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  80025f:	8b 43 20             	mov    0x20(%ebx),%eax
  800262:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800266:	8b 46 20             	mov    0x20(%esi),%eax
  800269:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026d:	c7 44 24 04 aa 17 80 	movl   $0x8017aa,0x4(%esp)
  800274:	00 
  800275:	c7 04 24 74 17 80 00 	movl   $0x801774,(%esp)
  80027c:	e8 69 04 00 00       	call   8006ea <cprintf>
  800281:	8b 43 20             	mov    0x20(%ebx),%eax
  800284:	39 46 20             	cmp    %eax,0x20(%esi)
  800287:	75 0e                	jne    800297 <check_regs+0x264>
  800289:	c7 04 24 84 17 80 00 	movl   $0x801784,(%esp)
  800290:	e8 55 04 00 00       	call   8006ea <cprintf>
  800295:	eb 11                	jmp    8002a8 <check_regs+0x275>
  800297:	c7 04 24 88 17 80 00 	movl   $0x801788,(%esp)
  80029e:	e8 47 04 00 00       	call   8006ea <cprintf>
  8002a3:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002a8:	8b 43 24             	mov    0x24(%ebx),%eax
  8002ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002af:	8b 46 24             	mov    0x24(%esi),%eax
  8002b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b6:	c7 44 24 04 ae 17 80 	movl   $0x8017ae,0x4(%esp)
  8002bd:	00 
  8002be:	c7 04 24 74 17 80 00 	movl   $0x801774,(%esp)
  8002c5:	e8 20 04 00 00       	call   8006ea <cprintf>
  8002ca:	8b 43 24             	mov    0x24(%ebx),%eax
  8002cd:	39 46 24             	cmp    %eax,0x24(%esi)
  8002d0:	75 0e                	jne    8002e0 <check_regs+0x2ad>
  8002d2:	c7 04 24 84 17 80 00 	movl   $0x801784,(%esp)
  8002d9:	e8 0c 04 00 00       	call   8006ea <cprintf>
  8002de:	eb 11                	jmp    8002f1 <check_regs+0x2be>
  8002e0:	c7 04 24 88 17 80 00 	movl   $0x801788,(%esp)
  8002e7:	e8 fe 03 00 00       	call   8006ea <cprintf>
  8002ec:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002f1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f8:	8b 46 28             	mov    0x28(%esi),%eax
  8002fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ff:	c7 44 24 04 b5 17 80 	movl   $0x8017b5,0x4(%esp)
  800306:	00 
  800307:	c7 04 24 74 17 80 00 	movl   $0x801774,(%esp)
  80030e:	e8 d7 03 00 00       	call   8006ea <cprintf>
  800313:	8b 43 28             	mov    0x28(%ebx),%eax
  800316:	39 46 28             	cmp    %eax,0x28(%esi)
  800319:	75 25                	jne    800340 <check_regs+0x30d>
  80031b:	c7 04 24 84 17 80 00 	movl   $0x801784,(%esp)
  800322:	e8 c3 03 00 00       	call   8006ea <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800327:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032e:	c7 04 24 b9 17 80 00 	movl   $0x8017b9,(%esp)
  800335:	e8 b0 03 00 00       	call   8006ea <cprintf>
	if (!mismatch)
  80033a:	85 ff                	test   %edi,%edi
  80033c:	74 23                	je     800361 <check_regs+0x32e>
  80033e:	eb 2f                	jmp    80036f <check_regs+0x33c>
	CHECK(esp, esp);
  800340:	c7 04 24 88 17 80 00 	movl   $0x801788,(%esp)
  800347:	e8 9e 03 00 00       	call   8006ea <cprintf>
	cprintf("Registers %s ", testname);
  80034c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80034f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800353:	c7 04 24 b9 17 80 00 	movl   $0x8017b9,(%esp)
  80035a:	e8 8b 03 00 00       	call   8006ea <cprintf>
  80035f:	eb 0e                	jmp    80036f <check_regs+0x33c>
		cprintf("OK\n");
  800361:	c7 04 24 84 17 80 00 	movl   $0x801784,(%esp)
  800368:	e8 7d 03 00 00       	call   8006ea <cprintf>
  80036d:	eb 0c                	jmp    80037b <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  80036f:	c7 04 24 88 17 80 00 	movl   $0x801788,(%esp)
  800376:	e8 6f 03 00 00       	call   8006ea <cprintf>
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
  8003a1:	c7 44 24 08 20 18 80 	movl   $0x801820,0x8(%esp)
  8003a8:	00 
  8003a9:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8003b0:	00 
  8003b1:	c7 04 24 c7 17 80 00 	movl   $0x8017c7,(%esp)
  8003b8:	e8 34 02 00 00       	call   8005f1 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003bd:	8b 50 08             	mov    0x8(%eax),%edx
  8003c0:	89 15 60 20 80 00    	mov    %edx,0x802060
  8003c6:	8b 50 0c             	mov    0xc(%eax),%edx
  8003c9:	89 15 64 20 80 00    	mov    %edx,0x802064
  8003cf:	8b 50 10             	mov    0x10(%eax),%edx
  8003d2:	89 15 68 20 80 00    	mov    %edx,0x802068
  8003d8:	8b 50 14             	mov    0x14(%eax),%edx
  8003db:	89 15 6c 20 80 00    	mov    %edx,0x80206c
  8003e1:	8b 50 18             	mov    0x18(%eax),%edx
  8003e4:	89 15 70 20 80 00    	mov    %edx,0x802070
  8003ea:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003ed:	89 15 74 20 80 00    	mov    %edx,0x802074
  8003f3:	8b 50 20             	mov    0x20(%eax),%edx
  8003f6:	89 15 78 20 80 00    	mov    %edx,0x802078
  8003fc:	8b 50 24             	mov    0x24(%eax),%edx
  8003ff:	89 15 7c 20 80 00    	mov    %edx,0x80207c
	during.eip = utf->utf_eip;
  800405:	8b 50 28             	mov    0x28(%eax),%edx
  800408:	89 15 80 20 80 00    	mov    %edx,0x802080
	during.eflags = utf->utf_eflags;
  80040e:	8b 50 2c             	mov    0x2c(%eax),%edx
  800411:	89 15 84 20 80 00    	mov    %edx,0x802084
	during.esp = utf->utf_esp;
  800417:	8b 40 30             	mov    0x30(%eax),%eax
  80041a:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  80041f:	c7 44 24 04 df 17 80 	movl   $0x8017df,0x4(%esp)
  800426:	00 
  800427:	c7 04 24 ed 17 80 00 	movl   $0x8017ed,(%esp)
  80042e:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800433:	ba d8 17 80 00       	mov    $0x8017d8,%edx
  800438:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
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
  800466:	c7 44 24 08 f4 17 80 	movl   $0x8017f4,0x8(%esp)
  80046d:	00 
  80046e:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800475:	00 
  800476:	c7 04 24 c7 17 80 00 	movl   $0x8017c7,(%esp)
  80047d:	e8 6f 01 00 00       	call   8005f1 <_panic>
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
  800491:	e8 78 0f 00 00       	call   80140e <set_pgfault_handler>

	__asm __volatile(
  800496:	50                   	push   %eax
  800497:	9c                   	pushf  
  800498:	58                   	pop    %eax
  800499:	0d d5 08 00 00       	or     $0x8d5,%eax
  80049e:	50                   	push   %eax
  80049f:	9d                   	popf   
  8004a0:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  8004a5:	8d 05 e0 04 80 00    	lea    0x8004e0,%eax
  8004ab:	a3 c0 20 80 00       	mov    %eax,0x8020c0
  8004b0:	58                   	pop    %eax
  8004b1:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  8004b7:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  8004bd:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  8004c3:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  8004c9:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  8004cf:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  8004d5:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  8004da:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  8004e0:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004e7:	00 00 00 
  8004ea:	89 3d 20 20 80 00    	mov    %edi,0x802020
  8004f0:	89 35 24 20 80 00    	mov    %esi,0x802024
  8004f6:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  8004fc:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  800502:	89 15 34 20 80 00    	mov    %edx,0x802034
  800508:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  80050e:	a3 3c 20 80 00       	mov    %eax,0x80203c
  800513:	89 25 48 20 80 00    	mov    %esp,0x802048
  800519:	8b 3d a0 20 80 00    	mov    0x8020a0,%edi
  80051f:	8b 35 a4 20 80 00    	mov    0x8020a4,%esi
  800525:	8b 2d a8 20 80 00    	mov    0x8020a8,%ebp
  80052b:	8b 1d b0 20 80 00    	mov    0x8020b0,%ebx
  800531:	8b 15 b4 20 80 00    	mov    0x8020b4,%edx
  800537:	8b 0d b8 20 80 00    	mov    0x8020b8,%ecx
  80053d:	a1 bc 20 80 00       	mov    0x8020bc,%eax
  800542:	8b 25 c8 20 80 00    	mov    0x8020c8,%esp
  800548:	50                   	push   %eax
  800549:	9c                   	pushf  
  80054a:	58                   	pop    %eax
  80054b:	a3 44 20 80 00       	mov    %eax,0x802044
  800550:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800551:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800558:	74 0c                	je     800566 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  80055a:	c7 04 24 54 18 80 00 	movl   $0x801854,(%esp)
  800561:	e8 84 01 00 00       	call   8006ea <cprintf>
	after.eip = before.eip;
  800566:	a1 c0 20 80 00       	mov    0x8020c0,%eax
  80056b:	a3 40 20 80 00       	mov    %eax,0x802040

	check_regs(&before, "before", &after, "after", "after page-fault");
  800570:	c7 44 24 04 07 18 80 	movl   $0x801807,0x4(%esp)
  800577:	00 
  800578:	c7 04 24 18 18 80 00 	movl   $0x801818,(%esp)
  80057f:	b9 20 20 80 00       	mov    $0x802020,%ecx
  800584:	ba d8 17 80 00       	mov    $0x8017d8,%edx
  800589:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
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
  8005b5:	a3 cc 20 80 00       	mov    %eax,0x8020cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005ba:	85 db                	test   %ebx,%ebx
  8005bc:	7e 07                	jle    8005c5 <libmain+0x30>
		binaryname = argv[0];
  8005be:	8b 06                	mov    (%esi),%eax
  8005c0:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  8005e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005ea:	e8 7a 0b 00 00       	call   801169 <sys_env_destroy>
}
  8005ef:	c9                   	leave  
  8005f0:	c3                   	ret    

008005f1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005f1:	55                   	push   %ebp
  8005f2:	89 e5                	mov    %esp,%ebp
  8005f4:	56                   	push   %esi
  8005f5:	53                   	push   %ebx
  8005f6:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8005f9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005fc:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800602:	e8 b4 0b 00 00       	call   8011bb <sys_getenvid>
  800607:	8b 55 0c             	mov    0xc(%ebp),%edx
  80060a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80060e:	8b 55 08             	mov    0x8(%ebp),%edx
  800611:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800615:	89 74 24 08          	mov    %esi,0x8(%esp)
  800619:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061d:	c7 04 24 80 18 80 00 	movl   $0x801880,(%esp)
  800624:	e8 c1 00 00 00       	call   8006ea <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800629:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062d:	8b 45 10             	mov    0x10(%ebp),%eax
  800630:	89 04 24             	mov    %eax,(%esp)
  800633:	e8 51 00 00 00       	call   800689 <vcprintf>
	cprintf("\n");
  800638:	c7 04 24 90 17 80 00 	movl   $0x801790,(%esp)
  80063f:	e8 a6 00 00 00       	call   8006ea <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800644:	cc                   	int3   
  800645:	eb fd                	jmp    800644 <_panic+0x53>

00800647 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800647:	55                   	push   %ebp
  800648:	89 e5                	mov    %esp,%ebp
  80064a:	53                   	push   %ebx
  80064b:	83 ec 14             	sub    $0x14,%esp
  80064e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800651:	8b 13                	mov    (%ebx),%edx
  800653:	8d 42 01             	lea    0x1(%edx),%eax
  800656:	89 03                	mov    %eax,(%ebx)
  800658:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80065b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80065f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800664:	75 19                	jne    80067f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800666:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80066d:	00 
  80066e:	8d 43 08             	lea    0x8(%ebx),%eax
  800671:	89 04 24             	mov    %eax,(%esp)
  800674:	e8 b3 0a 00 00       	call   80112c <sys_cputs>
		b->idx = 0;
  800679:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80067f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800683:	83 c4 14             	add    $0x14,%esp
  800686:	5b                   	pop    %ebx
  800687:	5d                   	pop    %ebp
  800688:	c3                   	ret    

00800689 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800689:	55                   	push   %ebp
  80068a:	89 e5                	mov    %esp,%ebp
  80068c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800692:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800699:	00 00 00 
	b.cnt = 0;
  80069c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006a3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006b4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006be:	c7 04 24 47 06 80 00 	movl   $0x800647,(%esp)
  8006c5:	e8 ba 01 00 00       	call   800884 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006ca:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006da:	89 04 24             	mov    %eax,(%esp)
  8006dd:	e8 4a 0a 00 00       	call   80112c <sys_cputs>

	return b.cnt;
}
  8006e2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006e8:	c9                   	leave  
  8006e9:	c3                   	ret    

008006ea <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006ea:	55                   	push   %ebp
  8006eb:	89 e5                	mov    %esp,%ebp
  8006ed:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006f0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fa:	89 04 24             	mov    %eax,(%esp)
  8006fd:	e8 87 ff ff ff       	call   800689 <vcprintf>
	va_end(ap);

	return cnt;
}
  800702:	c9                   	leave  
  800703:	c3                   	ret    
  800704:	66 90                	xchg   %ax,%ax
  800706:	66 90                	xchg   %ax,%ax
  800708:	66 90                	xchg   %ax,%ax
  80070a:	66 90                	xchg   %ax,%ax
  80070c:	66 90                	xchg   %ax,%ax
  80070e:	66 90                	xchg   %ax,%ax

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
  80078c:	e8 2f 0d 00 00       	call   8014c0 <__udivdi3>
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
  8007e5:	e8 06 0e 00 00       	call   8015f0 <__umoddi3>
  8007ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ee:	0f be 80 a3 18 80 00 	movsbl 0x8018a3(%eax),%eax
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
  80090c:	ff 24 85 60 19 80 00 	jmp    *0x801960(,%eax,4)
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
  8009ba:	83 f8 08             	cmp    $0x8,%eax
  8009bd:	7f 0b                	jg     8009ca <vprintfmt+0x146>
  8009bf:	8b 14 85 c0 1a 80 00 	mov    0x801ac0(,%eax,4),%edx
  8009c6:	85 d2                	test   %edx,%edx
  8009c8:	75 20                	jne    8009ea <vprintfmt+0x166>
				printfmt(putch, putdat, "error %d", err);
  8009ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ce:	c7 44 24 08 bb 18 80 	movl   $0x8018bb,0x8(%esp)
  8009d5:	00 
  8009d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	89 04 24             	mov    %eax,(%esp)
  8009e0:	e8 77 fe ff ff       	call   80085c <printfmt>
  8009e5:	e9 c3 fe ff ff       	jmp    8008ad <vprintfmt+0x29>
				printfmt(putch, putdat, "%s", p);
  8009ea:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009ee:	c7 44 24 08 c4 18 80 	movl   $0x8018c4,0x8(%esp)
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
  800a1d:	ba b4 18 80 00       	mov    $0x8018b4,%edx
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
  801197:	c7 44 24 08 e4 1a 80 	movl   $0x801ae4,0x8(%esp)
  80119e:	00 
  80119f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011a6:	00 
  8011a7:	c7 04 24 01 1b 80 00 	movl   $0x801b01,(%esp)
  8011ae:	e8 3e f4 ff ff       	call   8005f1 <_panic>
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
  8011e5:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  801229:	c7 44 24 08 e4 1a 80 	movl   $0x801ae4,0x8(%esp)
  801230:	00 
  801231:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801238:	00 
  801239:	c7 04 24 01 1b 80 00 	movl   $0x801b01,(%esp)
  801240:	e8 ac f3 ff ff       	call   8005f1 <_panic>
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
  80127c:	c7 44 24 08 e4 1a 80 	movl   $0x801ae4,0x8(%esp)
  801283:	00 
  801284:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80128b:	00 
  80128c:	c7 04 24 01 1b 80 00 	movl   $0x801b01,(%esp)
  801293:	e8 59 f3 ff ff       	call   8005f1 <_panic>
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
  8012cf:	c7 44 24 08 e4 1a 80 	movl   $0x801ae4,0x8(%esp)
  8012d6:	00 
  8012d7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012de:	00 
  8012df:	c7 04 24 01 1b 80 00 	movl   $0x801b01,(%esp)
  8012e6:	e8 06 f3 ff ff       	call   8005f1 <_panic>
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
  801322:	c7 44 24 08 e4 1a 80 	movl   $0x801ae4,0x8(%esp)
  801329:	00 
  80132a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801331:	00 
  801332:	c7 04 24 01 1b 80 00 	movl   $0x801b01,(%esp)
  801339:	e8 b3 f2 ff ff       	call   8005f1 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80133e:	83 c4 2c             	add    $0x2c,%esp
  801341:	5b                   	pop    %ebx
  801342:	5e                   	pop    %esi
  801343:	5f                   	pop    %edi
  801344:	5d                   	pop    %ebp
  801345:	c3                   	ret    

00801346 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  801367:	7e 28                	jle    801391 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801369:	89 44 24 10          	mov    %eax,0x10(%esp)
  80136d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801374:	00 
  801375:	c7 44 24 08 e4 1a 80 	movl   $0x801ae4,0x8(%esp)
  80137c:	00 
  80137d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801384:	00 
  801385:	c7 04 24 01 1b 80 00 	movl   $0x801b01,(%esp)
  80138c:	e8 60 f2 ff ff       	call   8005f1 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801391:	83 c4 2c             	add    $0x2c,%esp
  801394:	5b                   	pop    %ebx
  801395:	5e                   	pop    %esi
  801396:	5f                   	pop    %edi
  801397:	5d                   	pop    %ebp
  801398:	c3                   	ret    

00801399 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801399:	55                   	push   %ebp
  80139a:	89 e5                	mov    %esp,%ebp
  80139c:	57                   	push   %edi
  80139d:	56                   	push   %esi
  80139e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80139f:	be 00 00 00 00       	mov    $0x0,%esi
  8013a4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8013a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8013af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013b2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8013b5:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8013b7:	5b                   	pop    %ebx
  8013b8:	5e                   	pop    %esi
  8013b9:	5f                   	pop    %edi
  8013ba:	5d                   	pop    %ebp
  8013bb:	c3                   	ret    

008013bc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	57                   	push   %edi
  8013c0:	56                   	push   %esi
  8013c1:	53                   	push   %ebx
  8013c2:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8013c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013ca:	b8 0c 00 00 00       	mov    $0xc,%eax
  8013cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d2:	89 cb                	mov    %ecx,%ebx
  8013d4:	89 cf                	mov    %ecx,%edi
  8013d6:	89 ce                	mov    %ecx,%esi
  8013d8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	7e 28                	jle    801406 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013de:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013e2:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  8013e9:	00 
  8013ea:	c7 44 24 08 e4 1a 80 	movl   $0x801ae4,0x8(%esp)
  8013f1:	00 
  8013f2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013f9:	00 
  8013fa:	c7 04 24 01 1b 80 00 	movl   $0x801b01,(%esp)
  801401:	e8 eb f1 ff ff       	call   8005f1 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801406:	83 c4 2c             	add    $0x2c,%esp
  801409:	5b                   	pop    %ebx
  80140a:	5e                   	pop    %esi
  80140b:	5f                   	pop    %edi
  80140c:	5d                   	pop    %ebp
  80140d:	c3                   	ret    

0080140e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80140e:	55                   	push   %ebp
  80140f:	89 e5                	mov    %esp,%ebp
  801411:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801414:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  80141b:	75 70                	jne    80148d <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		//第一次要分配页面给异常stack使用
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W) < 0)
  80141d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801424:	00 
  801425:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80142c:	ee 
  80142d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801434:	e8 c0 fd ff ff       	call   8011f9 <sys_page_alloc>
  801439:	85 c0                	test   %eax,%eax
  80143b:	79 1c                	jns    801459 <set_pgfault_handler+0x4b>
			panic("set_pgfault_handler: sys_page_alloc failed");
  80143d:	c7 44 24 08 10 1b 80 	movl   $0x801b10,0x8(%esp)
  801444:	00 
  801445:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  80144c:	00 
  80144d:	c7 04 24 74 1b 80 00 	movl   $0x801b74,(%esp)
  801454:	e8 98 f1 ff ff       	call   8005f1 <_panic>
		//然后设置一下入口为_pgfault_upcall
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801459:	c7 44 24 04 97 14 80 	movl   $0x801497,0x4(%esp)
  801460:	00 
  801461:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801468:	e8 d9 fe ff ff       	call   801346 <sys_env_set_pgfault_upcall>
  80146d:	85 c0                	test   %eax,%eax
  80146f:	79 1c                	jns    80148d <set_pgfault_handler+0x7f>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed");
  801471:	c7 44 24 08 3c 1b 80 	movl   $0x801b3c,0x8(%esp)
  801478:	00 
  801479:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  801480:	00 
  801481:	c7 04 24 74 1b 80 00 	movl   $0x801b74,(%esp)
  801488:	e8 64 f1 ff ff       	call   8005f1 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80148d:	8b 45 08             	mov    0x8(%ebp),%eax
  801490:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  801495:	c9                   	leave  
  801496:	c3                   	ret    

00801497 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801497:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801498:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  80149d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80149f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax  //eip
  8014a2:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)  //原本的esp-4，用于ret
  8014a6:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx  //获得扩大后的原本的esp
  8014ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)      //填充ret地址
  8014af:	89 03                	mov    %eax,(%ebx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8014b1:	83 c4 08             	add    $0x8,%esp
	popal
  8014b4:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8014b5:	83 c4 04             	add    $0x4,%esp
	popfl
  8014b8:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8014b9:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8014ba:	c3                   	ret    
  8014bb:	66 90                	xchg   %ax,%ax
  8014bd:	66 90                	xchg   %ax,%ax
  8014bf:	90                   	nop

008014c0 <__udivdi3>:
  8014c0:	55                   	push   %ebp
  8014c1:	57                   	push   %edi
  8014c2:	56                   	push   %esi
  8014c3:	83 ec 0c             	sub    $0xc,%esp
  8014c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8014ca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8014ce:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8014d2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014dc:	89 ea                	mov    %ebp,%edx
  8014de:	89 0c 24             	mov    %ecx,(%esp)
  8014e1:	75 2d                	jne    801510 <__udivdi3+0x50>
  8014e3:	39 e9                	cmp    %ebp,%ecx
  8014e5:	77 61                	ja     801548 <__udivdi3+0x88>
  8014e7:	85 c9                	test   %ecx,%ecx
  8014e9:	89 ce                	mov    %ecx,%esi
  8014eb:	75 0b                	jne    8014f8 <__udivdi3+0x38>
  8014ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8014f2:	31 d2                	xor    %edx,%edx
  8014f4:	f7 f1                	div    %ecx
  8014f6:	89 c6                	mov    %eax,%esi
  8014f8:	31 d2                	xor    %edx,%edx
  8014fa:	89 e8                	mov    %ebp,%eax
  8014fc:	f7 f6                	div    %esi
  8014fe:	89 c5                	mov    %eax,%ebp
  801500:	89 f8                	mov    %edi,%eax
  801502:	f7 f6                	div    %esi
  801504:	89 ea                	mov    %ebp,%edx
  801506:	83 c4 0c             	add    $0xc,%esp
  801509:	5e                   	pop    %esi
  80150a:	5f                   	pop    %edi
  80150b:	5d                   	pop    %ebp
  80150c:	c3                   	ret    
  80150d:	8d 76 00             	lea    0x0(%esi),%esi
  801510:	39 e8                	cmp    %ebp,%eax
  801512:	77 24                	ja     801538 <__udivdi3+0x78>
  801514:	0f bd e8             	bsr    %eax,%ebp
  801517:	83 f5 1f             	xor    $0x1f,%ebp
  80151a:	75 3c                	jne    801558 <__udivdi3+0x98>
  80151c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801520:	39 34 24             	cmp    %esi,(%esp)
  801523:	0f 86 9f 00 00 00    	jbe    8015c8 <__udivdi3+0x108>
  801529:	39 d0                	cmp    %edx,%eax
  80152b:	0f 82 97 00 00 00    	jb     8015c8 <__udivdi3+0x108>
  801531:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801538:	31 d2                	xor    %edx,%edx
  80153a:	31 c0                	xor    %eax,%eax
  80153c:	83 c4 0c             	add    $0xc,%esp
  80153f:	5e                   	pop    %esi
  801540:	5f                   	pop    %edi
  801541:	5d                   	pop    %ebp
  801542:	c3                   	ret    
  801543:	90                   	nop
  801544:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801548:	89 f8                	mov    %edi,%eax
  80154a:	f7 f1                	div    %ecx
  80154c:	31 d2                	xor    %edx,%edx
  80154e:	83 c4 0c             	add    $0xc,%esp
  801551:	5e                   	pop    %esi
  801552:	5f                   	pop    %edi
  801553:	5d                   	pop    %ebp
  801554:	c3                   	ret    
  801555:	8d 76 00             	lea    0x0(%esi),%esi
  801558:	89 e9                	mov    %ebp,%ecx
  80155a:	8b 3c 24             	mov    (%esp),%edi
  80155d:	d3 e0                	shl    %cl,%eax
  80155f:	89 c6                	mov    %eax,%esi
  801561:	b8 20 00 00 00       	mov    $0x20,%eax
  801566:	29 e8                	sub    %ebp,%eax
  801568:	89 c1                	mov    %eax,%ecx
  80156a:	d3 ef                	shr    %cl,%edi
  80156c:	89 e9                	mov    %ebp,%ecx
  80156e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801572:	8b 3c 24             	mov    (%esp),%edi
  801575:	09 74 24 08          	or     %esi,0x8(%esp)
  801579:	89 d6                	mov    %edx,%esi
  80157b:	d3 e7                	shl    %cl,%edi
  80157d:	89 c1                	mov    %eax,%ecx
  80157f:	89 3c 24             	mov    %edi,(%esp)
  801582:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801586:	d3 ee                	shr    %cl,%esi
  801588:	89 e9                	mov    %ebp,%ecx
  80158a:	d3 e2                	shl    %cl,%edx
  80158c:	89 c1                	mov    %eax,%ecx
  80158e:	d3 ef                	shr    %cl,%edi
  801590:	09 d7                	or     %edx,%edi
  801592:	89 f2                	mov    %esi,%edx
  801594:	89 f8                	mov    %edi,%eax
  801596:	f7 74 24 08          	divl   0x8(%esp)
  80159a:	89 d6                	mov    %edx,%esi
  80159c:	89 c7                	mov    %eax,%edi
  80159e:	f7 24 24             	mull   (%esp)
  8015a1:	39 d6                	cmp    %edx,%esi
  8015a3:	89 14 24             	mov    %edx,(%esp)
  8015a6:	72 30                	jb     8015d8 <__udivdi3+0x118>
  8015a8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8015ac:	89 e9                	mov    %ebp,%ecx
  8015ae:	d3 e2                	shl    %cl,%edx
  8015b0:	39 c2                	cmp    %eax,%edx
  8015b2:	73 05                	jae    8015b9 <__udivdi3+0xf9>
  8015b4:	3b 34 24             	cmp    (%esp),%esi
  8015b7:	74 1f                	je     8015d8 <__udivdi3+0x118>
  8015b9:	89 f8                	mov    %edi,%eax
  8015bb:	31 d2                	xor    %edx,%edx
  8015bd:	e9 7a ff ff ff       	jmp    80153c <__udivdi3+0x7c>
  8015c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8015c8:	31 d2                	xor    %edx,%edx
  8015ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8015cf:	e9 68 ff ff ff       	jmp    80153c <__udivdi3+0x7c>
  8015d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015d8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8015db:	31 d2                	xor    %edx,%edx
  8015dd:	83 c4 0c             	add    $0xc,%esp
  8015e0:	5e                   	pop    %esi
  8015e1:	5f                   	pop    %edi
  8015e2:	5d                   	pop    %ebp
  8015e3:	c3                   	ret    
  8015e4:	66 90                	xchg   %ax,%ax
  8015e6:	66 90                	xchg   %ax,%ax
  8015e8:	66 90                	xchg   %ax,%ax
  8015ea:	66 90                	xchg   %ax,%ax
  8015ec:	66 90                	xchg   %ax,%ax
  8015ee:	66 90                	xchg   %ax,%ax

008015f0 <__umoddi3>:
  8015f0:	55                   	push   %ebp
  8015f1:	57                   	push   %edi
  8015f2:	56                   	push   %esi
  8015f3:	83 ec 14             	sub    $0x14,%esp
  8015f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8015fa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8015fe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801602:	89 c7                	mov    %eax,%edi
  801604:	89 44 24 04          	mov    %eax,0x4(%esp)
  801608:	8b 44 24 30          	mov    0x30(%esp),%eax
  80160c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801610:	89 34 24             	mov    %esi,(%esp)
  801613:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801617:	85 c0                	test   %eax,%eax
  801619:	89 c2                	mov    %eax,%edx
  80161b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80161f:	75 17                	jne    801638 <__umoddi3+0x48>
  801621:	39 fe                	cmp    %edi,%esi
  801623:	76 4b                	jbe    801670 <__umoddi3+0x80>
  801625:	89 c8                	mov    %ecx,%eax
  801627:	89 fa                	mov    %edi,%edx
  801629:	f7 f6                	div    %esi
  80162b:	89 d0                	mov    %edx,%eax
  80162d:	31 d2                	xor    %edx,%edx
  80162f:	83 c4 14             	add    $0x14,%esp
  801632:	5e                   	pop    %esi
  801633:	5f                   	pop    %edi
  801634:	5d                   	pop    %ebp
  801635:	c3                   	ret    
  801636:	66 90                	xchg   %ax,%ax
  801638:	39 f8                	cmp    %edi,%eax
  80163a:	77 54                	ja     801690 <__umoddi3+0xa0>
  80163c:	0f bd e8             	bsr    %eax,%ebp
  80163f:	83 f5 1f             	xor    $0x1f,%ebp
  801642:	75 5c                	jne    8016a0 <__umoddi3+0xb0>
  801644:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801648:	39 3c 24             	cmp    %edi,(%esp)
  80164b:	0f 87 e7 00 00 00    	ja     801738 <__umoddi3+0x148>
  801651:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801655:	29 f1                	sub    %esi,%ecx
  801657:	19 c7                	sbb    %eax,%edi
  801659:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80165d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801661:	8b 44 24 08          	mov    0x8(%esp),%eax
  801665:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801669:	83 c4 14             	add    $0x14,%esp
  80166c:	5e                   	pop    %esi
  80166d:	5f                   	pop    %edi
  80166e:	5d                   	pop    %ebp
  80166f:	c3                   	ret    
  801670:	85 f6                	test   %esi,%esi
  801672:	89 f5                	mov    %esi,%ebp
  801674:	75 0b                	jne    801681 <__umoddi3+0x91>
  801676:	b8 01 00 00 00       	mov    $0x1,%eax
  80167b:	31 d2                	xor    %edx,%edx
  80167d:	f7 f6                	div    %esi
  80167f:	89 c5                	mov    %eax,%ebp
  801681:	8b 44 24 04          	mov    0x4(%esp),%eax
  801685:	31 d2                	xor    %edx,%edx
  801687:	f7 f5                	div    %ebp
  801689:	89 c8                	mov    %ecx,%eax
  80168b:	f7 f5                	div    %ebp
  80168d:	eb 9c                	jmp    80162b <__umoddi3+0x3b>
  80168f:	90                   	nop
  801690:	89 c8                	mov    %ecx,%eax
  801692:	89 fa                	mov    %edi,%edx
  801694:	83 c4 14             	add    $0x14,%esp
  801697:	5e                   	pop    %esi
  801698:	5f                   	pop    %edi
  801699:	5d                   	pop    %ebp
  80169a:	c3                   	ret    
  80169b:	90                   	nop
  80169c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016a0:	8b 04 24             	mov    (%esp),%eax
  8016a3:	be 20 00 00 00       	mov    $0x20,%esi
  8016a8:	89 e9                	mov    %ebp,%ecx
  8016aa:	29 ee                	sub    %ebp,%esi
  8016ac:	d3 e2                	shl    %cl,%edx
  8016ae:	89 f1                	mov    %esi,%ecx
  8016b0:	d3 e8                	shr    %cl,%eax
  8016b2:	89 e9                	mov    %ebp,%ecx
  8016b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b8:	8b 04 24             	mov    (%esp),%eax
  8016bb:	09 54 24 04          	or     %edx,0x4(%esp)
  8016bf:	89 fa                	mov    %edi,%edx
  8016c1:	d3 e0                	shl    %cl,%eax
  8016c3:	89 f1                	mov    %esi,%ecx
  8016c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016c9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8016cd:	d3 ea                	shr    %cl,%edx
  8016cf:	89 e9                	mov    %ebp,%ecx
  8016d1:	d3 e7                	shl    %cl,%edi
  8016d3:	89 f1                	mov    %esi,%ecx
  8016d5:	d3 e8                	shr    %cl,%eax
  8016d7:	89 e9                	mov    %ebp,%ecx
  8016d9:	09 f8                	or     %edi,%eax
  8016db:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8016df:	f7 74 24 04          	divl   0x4(%esp)
  8016e3:	d3 e7                	shl    %cl,%edi
  8016e5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8016e9:	89 d7                	mov    %edx,%edi
  8016eb:	f7 64 24 08          	mull   0x8(%esp)
  8016ef:	39 d7                	cmp    %edx,%edi
  8016f1:	89 c1                	mov    %eax,%ecx
  8016f3:	89 14 24             	mov    %edx,(%esp)
  8016f6:	72 2c                	jb     801724 <__umoddi3+0x134>
  8016f8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8016fc:	72 22                	jb     801720 <__umoddi3+0x130>
  8016fe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801702:	29 c8                	sub    %ecx,%eax
  801704:	19 d7                	sbb    %edx,%edi
  801706:	89 e9                	mov    %ebp,%ecx
  801708:	89 fa                	mov    %edi,%edx
  80170a:	d3 e8                	shr    %cl,%eax
  80170c:	89 f1                	mov    %esi,%ecx
  80170e:	d3 e2                	shl    %cl,%edx
  801710:	89 e9                	mov    %ebp,%ecx
  801712:	d3 ef                	shr    %cl,%edi
  801714:	09 d0                	or     %edx,%eax
  801716:	89 fa                	mov    %edi,%edx
  801718:	83 c4 14             	add    $0x14,%esp
  80171b:	5e                   	pop    %esi
  80171c:	5f                   	pop    %edi
  80171d:	5d                   	pop    %ebp
  80171e:	c3                   	ret    
  80171f:	90                   	nop
  801720:	39 d7                	cmp    %edx,%edi
  801722:	75 da                	jne    8016fe <__umoddi3+0x10e>
  801724:	8b 14 24             	mov    (%esp),%edx
  801727:	89 c1                	mov    %eax,%ecx
  801729:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80172d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801731:	eb cb                	jmp    8016fe <__umoddi3+0x10e>
  801733:	90                   	nop
  801734:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801738:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80173c:	0f 82 0f ff ff ff    	jb     801651 <__umoddi3+0x61>
  801742:	e9 1a ff ff ff       	jmp    801661 <__umoddi3+0x71>
