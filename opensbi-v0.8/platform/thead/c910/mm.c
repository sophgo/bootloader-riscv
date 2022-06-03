#include <sbi/riscv_asm.h>
#include <sbi/sbi_bitops.h>
#include <sbi/sbi_string.h>
#include <sbi/riscv_barrier.h>
#include <sbi/riscv_encoding.h>
#include <sbi/sbi_hart.h>
#include <sbi/sbi_types.h>
#include <sbi/sbi_console.h>
#include "platform.h"
#include <stdio.h>

#define MANGO_VA_OFFSET	MANGO_PA_BASE

#define printf	sbi_printf

#define KB(n)	((n) * 1024UL)
#define MB(n)	(KB(n) * 1024)
#define GB(n)	(MB(n) * 1024)
#define TB(n)	(GB(n) * 1024)

#define MM_BARE		0
#define MM_SV39		8
#define MM_SV48		9

#define MM_PPN_SHIFT	12
#define MM_PPN_MASK	(~((1UL << MM_PPN_SHIFT) - 1))
#define MM_PPN_ALIGN	(1UL << MM_PPN_SHIFT)

#define SATP_MODE_SHIFT	60UL
#define SATP_MODE_MASK	(0x0fUL << SATP_MODE_SHIFT)

#define SATP_ASID_SHIFT	44UL
#define SATP_ASID_MASK	(0xffffUL << SATP_ASID_SHIFT)

#define SATP_PPN_SHIFT	0UL
#define SATP_PPN_MASK	(0x0fffffffffffUL << SATP_PPN_SHIFT)

#ifdef BIT_MASK
#undef BIT_MASK
#define BIT_MASK(n)	((1UL << (n)) - 1)
#endif

#define SV39_PTE_PPN2_SHIFT	28
#define SV39_PTE_PPN2_MASK	(BIT_MASK(26) << SV39_PTE_PPN2_SHIFT)

#define SV39_PTE_PPN1_SHIFT	19
#define SV39_PTE_PPN1_MASK	(BIT_MASK(9) << SV39_PTE_PPN1_SHIFT)

#define SV39_PTE_PPN0_SHIFT	10
#define SV39_PTE_PPN0_MASK	(BIT_MASK(9) << SV39_PTE_PPN0_SHIFT)

#define SV39_PTE_PPN_SHIFT	SV39_PTE_PPN0_SHIFT
#define SV39_PTE_PPN_MASK	(BIT_MASK(44) << SV39_PTE_PPN_SHIFT)

#define SV39_PTE_RSW_SHIFT	8
#define SV39_PTE_RSW_MASK	(BIT_MASK(2) << SV39_PTE_RSW_SHIFT)

#define SV39_PTE_D_SHIFT	7
#define SV39_PTE_D_MASK		(1 << SV39_PTE_D_SHIFT)

#define SV39_PTE_A_SHIFT	6
#define SV39_PTE_A_MASK		(1 << SV39_PTE_A_SHIFT)

#define SV39_PTE_G_SHIFT	5
#define SV39_PTE_G_MASK		(1 << SV39_PTE_G_SHIFT)

#define SV39_PTE_U_SHIFT	4
#define SV39_PTE_U_MASK		(1 << SV39_PTE_U_SHIFT)

#define SV39_PTE_X_SHIFT	3
#define SV39_PTE_X_MASK		(1 << SV39_PTE_X_SHIFT)

#define SV39_PTE_W_SHIFT	2
#define SV39_PTE_W_MASK		(1 << SV39_PTE_W_SHIFT)

#define SV39_PTE_R_SHIFT	1
#define SV39_PTE_R_MASK		(1 << SV39_PTE_R_SHIFT)

#define SV39_PTE_V_SHIFT	0
#define SV39_PTE_V_MASK		(1 << SV39_PTE_V_SHIFT)

#define SV39_THEAD_PTE_SO_SHIFT	63
#define SV39_THEAD_PTE_SO_MASK	(1UL << SV39_THEAD_PTE_SO_SHIFT)

#define SV39_THEAD_PTE_C_SHIFT	62
#define SV39_THEAD_PTE_C_MASK	(1UL << SV39_THEAD_PTE_C_SHIFT)

#define SV39_THEAD_PTE_B_SHIFT	61
#define SV39_THEAD_PTE_B_MASK	(1UL << SV39_THEAD_PTE_B_SHIFT)

#define SV39_THEAD_PTE_SH_SHIFT	60
#define SV39_THEAD_PTE_SH_MASK	(1UL << SV39_THEAD_PTE_SH_SHIFT)

#define SV39_THEAD_PTE_SE_SHIFT	59
#define SV39_THEAD_PTE_SE_MASK	(1UL << SV39_THEAD_PTE_SE_SHIFT)


static unsigned long __aligned(MM_PPN_ALIGN) mm_table[32];

static unsigned long mk_io_pte(unsigned long pa)
{
	return (((pa >> MM_PPN_SHIFT) << SV39_PTE_PPN_SHIFT) &
		SV39_PTE_PPN_MASK)	|
		SV39_PTE_R_MASK		|
		SV39_PTE_W_MASK		|
		SV39_PTE_D_MASK		|
		SV39_PTE_A_MASK		|
		SV39_PTE_V_MASK		|
		SV39_THEAD_PTE_SH_MASK	|
		SV39_THEAD_PTE_SO_MASK;
}

static unsigned long mk_normal_pte(unsigned long pa)
{
	return (((pa >> MM_PPN_SHIFT) << SV39_PTE_PPN_SHIFT) &
		SV39_PTE_PPN_MASK)	|
		SV39_PTE_R_MASK		|
		SV39_PTE_W_MASK		|
		SV39_PTE_X_MASK		|
		SV39_PTE_D_MASK		|
		SV39_PTE_A_MASK		|
		SV39_PTE_V_MASK		|
		SV39_THEAD_PTE_SH_MASK	|
		SV39_THEAD_PTE_B_MASK	|
		SV39_THEAD_PTE_C_MASK;

}

static void mm_gen_table(unsigned long *base)
{
	int i;

	base[0] = mk_normal_pte(MANGO_PA_BASE);
	base[1] = mk_io_pte(MANGO_IO_BASE);

	for (i = 0; i < 2; ++i)
		printf("%4d: %016lx\n", i, base[i]);
}

int mm_setup_table(unsigned long *_base)
{
	int mode, asid;
	unsigned long base;
	unsigned long ppn, satp;

	mode = MM_SV39;
	asid = 0;
	base = (unsigned long)_base;

	printf("set mmu table, mode %d, asid %d, base %016lx\n",
	       mode, asid, base);

	ppn = base >> MM_PPN_SHIFT;

	satp = 0;
	satp |= ((unsigned long)ppn << SATP_PPN_SHIFT) & SATP_PPN_MASK;
	satp |= ((unsigned long)asid << SATP_ASID_SHIFT) & SATP_ASID_MASK;
	satp |= ((unsigned long)mode << SATP_MODE_SHIFT) & SATP_MODE_MASK;

	printf("set satp %016lx\n", satp);

	csr_write(satp, satp);

	printf("get satp %016lx\n", csr_read(satp));

	asm volatile ("sfence.vma" : : : "memory");

	return 0;
}

void __attribute__((noreturn))
sbi_hart_switch_mode_with_mmu(unsigned long arg0, unsigned long arg1,
		     unsigned long next_addr, unsigned long next_mode,
		     bool next_virt)
{
#if __riscv_xlen == 32
	unsigned long val, valH;
#else
	unsigned long val;
#endif

	switch (next_mode) {
	case PRV_M:
		break;
	case PRV_S:
		if (!misa_extension('S'))
			sbi_hart_hang();
		break;
	case PRV_U:
		if (!misa_extension('U'))
			sbi_hart_hang();
		break;
	default:
		sbi_hart_hang();
	}

	val = csr_read(CSR_MSTATUS);
	val = INSERT_FIELD(val, MSTATUS_MPP, next_mode);
	val = INSERT_FIELD(val, MSTATUS_MPIE, 0);
#if __riscv_xlen == 32
	if (misa_extension('H')) {
		valH = csr_read(CSR_MSTATUSH);
		if (next_virt)
			valH = INSERT_FIELD(valH, MSTATUSH_MPV, 1);
		else
			valH = INSERT_FIELD(valH, MSTATUSH_MPV, 0);
		csr_write(CSR_MSTATUSH, valH);
	}
#else
	if (misa_extension('H')) {
		if (next_virt)
			val = INSERT_FIELD(val, MSTATUS_MPV, 1);
		else
			val = INSERT_FIELD(val, MSTATUS_MPV, 0);
	}
#endif
	csr_write(CSR_MSTATUS, val);
	csr_write(CSR_MEPC, next_addr);

	if (next_mode == PRV_S) {
		csr_write(CSR_STVEC, next_addr);
		csr_write(CSR_SSCRATCH, 0);
		csr_write(CSR_SIE, 0);
#if 0
		csr_write(CSR_SATP, 0);
#else
		unsigned long hartid = csr_read(CSR_MHARTID);

		if (hartid == 0) {
			mm_gen_table(mm_table);
			/* copy kernel to its physicall address */
			const unsigned long text_size = 32 * 1024 * 1024;
			sbi_memcpy((void *)(MANGO_VA_OFFSET + next_addr),
				   (void *)next_addr, text_size);

			/* clear original kernel address */
			sbi_memset((void *)next_addr, 0xdeadbeef, text_size);

			__asm__ __volatile__("fence.i");

			arg1 -= MANGO_VA_OFFSET;
		} else {
			/* other cores bringup by linux kernel, which uses real
			 * physicall address of vmlinux
			 */

			next_addr -= MANGO_VA_OFFSET;
			/* reconfig vmlinux entry to virtual address which
			 * mapped before
			 */
			csr_write(CSR_MEPC, next_addr);
			csr_write(CSR_STVEC, next_addr);
		}
		mm_setup_table(mm_table);
#endif
	} else if (next_mode == PRV_U) {
		csr_write(CSR_UTVEC, next_addr);
		csr_write(CSR_USCRATCH, 0);
		csr_write(CSR_UIE, 0);
	}

	register unsigned long a0 asm("a0") = arg0;
	register unsigned long a1 asm("a1") = arg1;
	__asm__ __volatile__("mret" : : "r"(a0), "r"(a1));
	__builtin_unreachable();
}
