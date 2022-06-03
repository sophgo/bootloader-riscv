/*
 * SPDX-License-Identifier: BSD-2-Clause
 */

#include <sbi/riscv_encoding.h>
#include <sbi/riscv_io.h>
#include <sbi/sbi_console.h>
#include <sbi/sbi_const.h>
#include <sbi/sbi_hart.h>
#include <sbi/sbi_hsm.h>
#include <sbi/sbi_trap.h>
#include <sbi/sbi_platform.h>
#include <sbi/sbi_bitops.h>
#include <sbi/riscv_locks.h>
#include <sbi_utils/irqchip/plic.h>
#include <sbi_utils/serial/uart8250.h>
#include <sbi_utils/sys/clint.h>
#include <sbi_utils/serial/fdt_serial.h>
#include <sbi_utils/fdt/fdt_helper.h>
#include <libfdt.h>
#include "platform.h"

#ifndef ARRAY_SIZE
#define ARRAY_SIZE(a)	(sizeof(a) / sizeof((a)[0]))
#endif

static struct sg2040_regs_struct sg2040_regs;

#ifndef __SG_QEMU__
static struct clint_data clint = {
	.msip_addr = 0, /* Updated at cold boot time */
	.mtimecmp_addr = 0,
	.first_hartid = 0,
	.hart_count = SG2040_HART_COUNT,
	.has_64bit_mmio = FALSE,
};
#endif

static spinlock_t init_lock = SPIN_LOCK_INITIALIZER;
int need_set_cpu = 1;
unsigned long mcpuid, sub_revision;
struct pmp pmp_addr[32] = {{0, 0}};
unsigned long pmp_attr[9] = {0};
unsigned long pmp_base, pmp_entry, pmp_cfg, mrvbr, mrmr;

#if 0
static void parse_dts()
{
	int off;
	const void *prop;
	void *fdt = sbi_scratch_thishart_arg1_ptr();

	fdt_parse_compat_addr(fdt, &pmp_base, "pmp");
	fdt_parse_compat_addr(fdt, &mrvbr, "mrvbr");
	fdt_parse_compat_addr(fdt, &mrmr, "mrmr");

	sbi_printf("pmp: 0x%lx\n", pmp_base);
	sbi_printf("mrvbr: 0x%lx\n", mrvbr);
	sbi_printf("mrmr: 0x%lx\n", mrmr);

	off = fdt_path_offset(fdt, "/core_release");
	if (off < 0)
		return;

	prop = fdt_getprop(fdt, off, "set_cpu_type", NULL);
	sbi_printf("prop: %s\n", (char *)prop);
	if (!sbi_strcmp(prop, "uboot"))
		need_set_cpu = 0;
}
#endif

#define PMP_CFG_R	BIT(0)
#define PMP_CFG_W	BIT(1)
#define PMP_CFG_X	BIT(2)

#define PMP_CFG_A_SHIFT	3
#define PMP_CFG_A_OFF	(0UL << PMP_CFG_A_SHIFT)
#define PMP_CFG_A_TOR	(1UL << PMP_CFG_A_SHIFT)
#define PMP_CFG_A_NA4	(2UL <<	PMP_CFG_A_SHIFT)/* not supported by c910 */
#define PMP_CFG_A_NAPOT	(3UL << PMP_CFG_A_SHIFT)

#define MANGO_PA_MAX	((1UL << 40) - 1UL)

void setup_pmp(void)
{
       csr_write(pmpaddr0, MANGO_PA_MAX >> 2);
       csr_write(pmpcfg0, PMP_CFG_R | PMP_CFG_W | PMP_CFG_X | PMP_CFG_A_TOR);
}

void setup_cpu(void)
{
	sg2040_regs.mcor     = 0x70013;
	sg2040_regs.mhcr     = 0x11ff;
	sg2040_regs.mccr2    = 0xe0410009;
	sg2040_regs.mhint    = 0x6e30c;
#ifndef MANGO_DVM
	/* disable sfence.vma broadcast */
	sg2040_regs.mhint    |= 1 << 21;
	/* disable fence rw broadcast */
	sg2040_regs.mhint    |= 1 << 22;
	/* disable fence.i broadcast */
	sg2040_regs.mhint    |= 1 << 23;
#endif
	/* enable MAEE */
	sg2040_regs.mxstatus = 0x638000;

	csr_write(CSR_MCOR, sg2040_regs.mcor);
	csr_write(CSR_MHCR, sg2040_regs.mhcr);
	csr_write(CSR_MHINT, sg2040_regs.mhint);
	csr_write(CSR_MXSTATUS, sg2040_regs.mxstatus);
	csr_write(CSR_MCCR2, sg2040_regs.mccr2);

}

static int sg2040_early_init(bool cold_boot)
{
	if (cold_boot) {
		/* Read TWICE!!! */
		mcpuid = csr_read(CSR_MCPUID);
		mcpuid = csr_read(CSR_MCPUID);

		/* Get bit [23...18] */
		sub_revision = (mcpuid & 0xfc0000) >> 18;
		sbi_printf("sub_revision: %ld\n", sub_revision);

		// parse_dts();
		sg2040_regs.plic_base_addr = SG2040_PLIC_BASE;
		sg2040_regs.msip_base_addr = SG2040_MSIP_BASE;
		sg2040_regs.mtimecmp_base_addr = SG2040_MTIMECMP_BASE;

		setup_pmp();
		setup_cpu();
	}

	if (!need_set_cpu)
		return 0;

	spin_lock(&init_lock);

	if (cold_boot) {
		/* Load from boot core */
		sg2040_regs.pmpaddr0 = csr_read(CSR_PMPADDR0);
		sg2040_regs.pmpaddr1 = csr_read(CSR_PMPADDR1);
		//sg2040_regs.pmpaddr2 = csr_read(CSR_PMPADDR2);
		//sg2040_regs.pmpaddr3 = csr_read(CSR_PMPADDR3);
		//sg2040_regs.pmpaddr4 = csr_read(CSR_PMPADDR4);
		//sg2040_regs.pmpaddr5 = csr_read(CSR_PMPADDR5);
		//sg2040_regs.pmpaddr6 = csr_read(CSR_PMPADDR6);
		//sg2040_regs.pmpaddr7 = csr_read(CSR_PMPADDR7);
		sg2040_regs.pmpcfg0  = csr_read(CSR_PMPCFG0);

		sg2040_regs.mcor     = csr_read(CSR_MCOR);
		sg2040_regs.mhcr     = csr_read(CSR_MHCR);
		sg2040_regs.mccr2    = csr_read(CSR_MCCR2);
		sg2040_regs.mhint    = csr_read(CSR_MHINT);
		sg2040_regs.mxstatus = csr_read(CSR_MXSTATUS);
	} else {
		/* Store to other core */
		csr_write(CSR_PMPADDR0, sg2040_regs.pmpaddr0);
		csr_write(CSR_PMPADDR1, sg2040_regs.pmpaddr1);
		//csr_write(CSR_PMPADDR2, sg2040_regs.pmpaddr2);
		//csr_write(CSR_PMPADDR3, sg2040_regs.pmpaddr3);
		//csr_write(CSR_PMPADDR4, sg2040_regs.pmpaddr4);
		//csr_write(CSR_PMPADDR5, sg2040_regs.pmpaddr5);
		//csr_write(CSR_PMPADDR6, sg2040_regs.pmpaddr6);
		//csr_write(CSR_PMPADDR7, sg2040_regs.pmpaddr7);
		csr_write(CSR_PMPCFG0, sg2040_regs.pmpcfg0);

		csr_write(CSR_MCOR, sg2040_regs.mcor);
		csr_write(CSR_MHCR, sg2040_regs.mhcr);
		csr_write(CSR_MHINT, sg2040_regs.mhint);
		csr_write(CSR_MXSTATUS, sg2040_regs.mxstatus);
	}

	spin_unlock(&init_lock);

	return 0;
}

static void sg2040_delegate_more_traps()
{
	unsigned long exceptions = csr_read(CSR_MEDELEG);

	/* Delegate 0 ~ 7 exceptions to S-mode */
	exceptions |= ((1U << CAUSE_MISALIGNED_FETCH) | (1U << CAUSE_FETCH_ACCESS) |
		(1U << CAUSE_ILLEGAL_INSTRUCTION) | (1U << CAUSE_BREAKPOINT) |
		(1U << CAUSE_MISALIGNED_LOAD) | (1U << CAUSE_LOAD_ACCESS) |
		(1U << CAUSE_MISALIGNED_STORE) | (1U << CAUSE_STORE_ACCESS));

	csr_write(CSR_MEDELEG, exceptions);
}

static int sg2040_final_init(bool cold_boot)
{
	sg2040_delegate_more_traps();

	return 0;
}

static int sg2040_irqchip_init(bool cold_boot)
{
	/* Delegate plic enable into S-mode */
	#ifndef __SG_QEMU__
	writel(SG2040_PLIC_DELEG_ENABLE,
		(void *)sg2040_regs.plic_base_addr + SG2040_PLIC_DELEG_OFFSET);
	#endif
	return 0;
}

static int sg2040_ipi_init(bool cold_boot)
{
	#ifndef __SG_QEMU__
	int rc;

	if (cold_boot) {
		clint.msip_addr = sg2040_regs.msip_base_addr;
		rc = clint_cold_ipi_init_range(0, SG2040_HART_COUNT, &clint);
		if (rc)
			return rc;
	}

	return clint_warm_ipi_init();
	#else
	return 0;
	#endif
}

static int sg2040_timer_init(bool cold_boot)
{
	#ifndef __SG_QEMU__
	int ret;

	if (cold_boot) {
		clint.mtimecmp_addr = sg2040_regs.mtimecmp_base_addr;
		ret = clint_cold_timer_init_range(0, SG2040_HART_COUNT, &clint, NULL);
		if (ret)
			return ret;
	}

	return clint_warm_timer_init();
	#else
	return 0;
	#endif
}

static int sg2040_system_reset(u32 type)
{
	asm volatile ("ebreak");
	return 0;
}

void sbi_pmu_init(void)
{
	unsigned long interrupts;

	interrupts = csr_read(CSR_MIDELEG) | (1 << 17);
	csr_write(CSR_MIDELEG, interrupts);

	/* CSR_MCOUNTEREN has already been set in mstatus_init() */
	csr_write(CSR_MCOUNTERWEN, 0xffffffff);
	csr_write(CSR_MHPMEVENT3, 1);
	csr_write(CSR_MHPMEVENT4, 2);
	csr_write(CSR_MHPMEVENT5, 3);
	csr_write(CSR_MHPMEVENT6, 4);
	csr_write(CSR_MHPMEVENT7, 5);
	csr_write(CSR_MHPMEVENT8, 6);
	csr_write(CSR_MHPMEVENT9, 7);
	csr_write(CSR_MHPMEVENT10, 8);
	csr_write(CSR_MHPMEVENT11, 9);
	csr_write(CSR_MHPMEVENT12, 10);
	csr_write(CSR_MHPMEVENT13, 11);
	csr_write(CSR_MHPMEVENT14, 12);
	csr_write(CSR_MHPMEVENT15, 13);
	csr_write(CSR_MHPMEVENT16, 14);
	csr_write(CSR_MHPMEVENT17, 15);
	csr_write(CSR_MHPMEVENT18, 16);
	csr_write(CSR_MHPMEVENT19, 17);
	csr_write(CSR_MHPMEVENT20, 18);
	csr_write(CSR_MHPMEVENT21, 19);
	csr_write(CSR_MHPMEVENT22, 20);
	csr_write(CSR_MHPMEVENT23, 21);
	csr_write(CSR_MHPMEVENT24, 22);
	csr_write(CSR_MHPMEVENT25, 23);
	csr_write(CSR_MHPMEVENT26, 24);
	csr_write(CSR_MHPMEVENT27, 25);
	csr_write(CSR_MHPMEVENT28, 26);
}

void sbi_pmu_map(unsigned long idx, unsigned long event_id)
{
	switch (idx) {
	case 3:
		csr_write(CSR_MHPMEVENT3, event_id);
		break;
	case 4:
		csr_write(CSR_MHPMEVENT4, event_id);
		break;
	case 5:
		csr_write(CSR_MHPMEVENT5, event_id);
		break;
	case 6:
		csr_write(CSR_MHPMEVENT6, event_id);
		break;
	case 7:
		csr_write(CSR_MHPMEVENT7, event_id);
		break;
	case 8:
		csr_write(CSR_MHPMEVENT8, event_id);
		break;
	case 9:
		csr_write(CSR_MHPMEVENT9, event_id);
		break;
	case 10:
		csr_write(CSR_MHPMEVENT10, event_id);
		break;
	case 11:
		csr_write(CSR_MHPMEVENT11, event_id);
		break;
	case 12:
		csr_write(CSR_MHPMEVENT12, event_id);
		break;
	case 13:
		csr_write(CSR_MHPMEVENT13, event_id);
		break;
	case 14:
		csr_write(CSR_MHPMEVENT14, event_id);
		break;
	case 15:
		csr_write(CSR_MHPMEVENT15, event_id);
		break;
	case 16:
		csr_write(CSR_MHPMEVENT16, event_id);
		break;
	case 17:
		csr_write(CSR_MHPMEVENT17, event_id);
		break;
	case 18:
		csr_write(CSR_MHPMEVENT18, event_id);
		break;
	case 19:
		csr_write(CSR_MHPMEVENT19, event_id);
		break;
	case 20:
		csr_write(CSR_MHPMEVENT20, event_id);
		break;
	case 21:
		csr_write(CSR_MHPMEVENT21, event_id);
		break;
	case 22:
		csr_write(CSR_MHPMEVENT22, event_id);
		break;
	case 23:
		csr_write(CSR_MHPMEVENT23, event_id);
		break;
	case 24:
		csr_write(CSR_MHPMEVENT24, event_id);
		break;
	case 25:
		csr_write(CSR_MHPMEVENT25, event_id);
		break;
	case 26:
		csr_write(CSR_MHPMEVENT26, event_id);
		break;
	case 27:
		csr_write(CSR_MHPMEVENT27, event_id);
		break;
	case 28:
		csr_write(CSR_MHPMEVENT28, event_id);
		break;
	case 29:
		csr_write(CSR_MHPMEVENT29, event_id);
		break;
	case 30:
		csr_write(CSR_MHPMEVENT30, event_id);
		break;
	case 31:
		csr_write(CSR_MHPMEVENT31, event_id);
		break;
	}
}

void sbi_set_pmu(unsigned long type, unsigned long idx, unsigned long event_id)
{
	switch (type) {
	case 2:
		sbi_pmu_map(idx, event_id);
		break;
	default:
		sbi_pmu_init();
		break;
	}
}

static int sg2040_vendor_ext_provider(long extid, long funcid,
				unsigned long *args,
				unsigned long *out_value,
				struct sbi_trap_info *out_trap)
{
	switch (extid) {
	case SBI_EXT_VENDOR_SG2040_SET_PMU:
		sbi_set_pmu(args[0], args[1], args[2]);
		break;
	default:
		sbi_printf("Unsupported private sbi call: %ld\n", extid);
		asm volatile ("ebreak");
	}
	return 0;
}

static int sg2040_console_init(void)
{
	return uart8250_init(
			SG2040_UART0_ADDRBASE,
			SG2040_UART0_FREQ,
			SG2040_CONSOLE_BDRATE,
			2, 0);
}

const struct sbi_platform_operations platform_ops = {
	.early_init          = sg2040_early_init,
	.final_init          = sg2040_final_init,

	.irqchip_init        = sg2040_irqchip_init,

	.ipi_init            = sg2040_ipi_init,
	.ipi_send            = clint_ipi_send,
	.ipi_clear           = clint_ipi_clear,

	.timer_init          = sg2040_timer_init,
	.timer_value	     = mango_timer_value,
	.timer_event_start   = clint_timer_event_start,

	.console_putc        = uart8250_putc,
	.console_getc        = uart8250_getc,
	.console_init        = sg2040_console_init,

	.system_reset        = sg2040_system_reset,

	.vendor_ext_provider = sg2040_vendor_ext_provider,
};

const struct sbi_platform platform = {
	.opensbi_version     = OPENSBI_VERSION,
	.platform_version    = SBI_PLATFORM_VERSION(0x0, 0x01),
	.name                = "Sophgo manGo sg2040",
	.features            = SBI_SOPHGO_FEATURES,
	.hart_count          = SG2040_HART_COUNT,
	.hart_stack_size     = SBI_PLATFORM_DEFAULT_HART_STACK_SIZE,
	.platform_ops_addr   = (unsigned long)&platform_ops
};
