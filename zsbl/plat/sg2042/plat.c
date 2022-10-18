#if defined ARCH_ARM64
#include <stdint.h>
#include <string.h>
#include <stdarg.h>
#include <mmu.h>
#include <cache.h>
#include <irq.h>
#include <arch.h>
#include <timer.h>
#include <memmap.h>
#include <platform.h>
#include <framework/module.h>
#include <framework/common.h>

struct mm_region default_memory_map[] = {
	{
		/* AXI SRAM */
		.virt = 0x10000000UL,
		.phys = 0x10000000UL,
		.size = 0x00200000UL,
		.attrs = PTE_BLOCK_MEMTYPE(MT_NORMAL) |
			 PTE_BLOCK_INNER_SHARE
	},
	{
		.virt = 0x10200000UL,
		.phys = 0x10200000UL,
		.size = 0xEFE00000UL,
		.attrs = PTE_BLOCK_MEMTYPE(MT_DEVICE_NGNRNE) |
			PTE_BLOCK_NON_SHARE |
			PTE_BLOCK_PXN | PTE_BLOCK_UXN
	},
	{
		.virt = 0x6000000UL,
		.phys = 0x6000000UL,
		.size = 0x4000000UL,
		.attrs = PTE_BLOCK_MEMTYPE(MT_DEVICE_NGNRNE) |
			PTE_BLOCK_NON_SHARE |
			PTE_BLOCK_PXN | PTE_BLOCK_UXN
	},
	{
		/* List terminator */
		0,
	}
};
#endif

#if defined ARCH_RISCV
#include <sbi/sbi_types.h>
#include <sbi/riscv_asm.h>
#include <framework/module.h>
static struct sg2040_regs_struct {
	u64 pmpaddr0;
	u64 pmpaddr1;
	u64 pmpaddr2;
	u64 pmpaddr3;
	u64 pmpaddr4;
	u64 pmpaddr5;
	u64 pmpaddr6;
	u64 pmpaddr7;
	u64 pmpcfg0;
	u64 msmpr;
	u64 mcor;
	u64 mhcr;
	u64 mccr2;
	u64 mhint;
	u64 mhint2;
	u64 mxstatus;
	u64 plic_base_addr;
	u64 msip_base_addr;
	u64 mtimecmp_base_addr;
} sg2040_regs;

static struct sg2040_regs_struct sg2040_regs;
int platform_setup_cpu(void)
{
	/* workaround lr/sc livelock */
	sg2040_regs.mhint2    = csr_read(CSR_MHINT2);
	sg2040_regs.mhint2   |= 3 << 7;

	csr_write(CSR_MHINT2, sg2040_regs.mhint2);

	return 0;
}

plat_init(platform_setup_cpu);

#endif
