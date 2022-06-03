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
#include <sbi/riscv_locks.h>
#include <sbi_utils/irqchip/plic.h>
#include <sbi_utils/serial/uart8250.h>
#include <sbi_utils/sys/clint.h>
#include <sbi_utils/serial/fdt_serial.h>
#include <sbi_utils/fdt/fdt_helper.h>
#include <libfdt.h>
#include "platform.h"

static struct c910_regs_struct c910_regs;

static struct clint_data clint = {
	.addr = 0, /* Updated at cold boot time */
	.first_hartid = 0,
	.hart_count = C910_HART_COUNT,
	.has_64bit_mmio = FALSE,
};

static spinlock_t init_lock = SPIN_LOCK_INITIALIZER;
int need_set_cpu = 1;
unsigned long mcpuid, sub_revision;
struct pmp pmp_addr[32] = {{0, 0}};
unsigned long pmp_attr[9] = {0};
unsigned long pmp_base, pmp_entry, pmp_cfg, mrvbr, mrmr;

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

static int c910_early_init(bool cold_boot)
{
	if (cold_boot) {
		/* Read TWICE!!! */
		mcpuid = csr_read(CSR_MCPUID);
		mcpuid = csr_read(CSR_MCPUID);

		/* Get bit [23...18] */
		sub_revision = (mcpuid & 0xfc0000) >> 18;
		sbi_printf("sub_revision: %ld\n", sub_revision);

		parse_dts();
		c910_regs.plic_base_addr = csr_read(CSR_PLIC_BASE);
		c910_regs.clint_base_addr =
			c910_regs.plic_base_addr + C910_PLIC_CLINT_OFFSET;
	}

	sbi_printf("need_set_cpu: %d\n", need_set_cpu);

	if (!need_set_cpu)
		return 0;

	spin_lock(&init_lock);

	pmp_entry = pmp_base + csr_read(CSR_MHARTID) * 0x4000 + 0x100;
	pmp_cfg = pmp_base + csr_read(CSR_MHARTID) * 0x4000 + 0x0;

	if (cold_boot) {
		/* Load from boot core */
		if (sub_revision < 3) {
			c910_regs.pmpaddr0 = csr_read(CSR_PMPADDR0);
			c910_regs.pmpaddr1 = csr_read(CSR_PMPADDR1);
			c910_regs.pmpaddr2 = csr_read(CSR_PMPADDR2);
			c910_regs.pmpaddr3 = csr_read(CSR_PMPADDR3);
			c910_regs.pmpaddr4 = csr_read(CSR_PMPADDR4);
			c910_regs.pmpaddr5 = csr_read(CSR_PMPADDR5);
			c910_regs.pmpaddr6 = csr_read(CSR_PMPADDR6);
			c910_regs.pmpaddr7 = csr_read(CSR_PMPADDR7);
			c910_regs.pmpcfg0  = csr_read(CSR_PMPCFG0);
		} else if (sub_revision == 3) {
			sbi_printf("==============================\n");
			for (int i = 0, j = 0; i < 32; i++) {
				pmp_addr[i].start = readl((void *)(pmp_entry + j * 4));
				sbi_printf("0x%lx\n", pmp_entry + j * 4);
				j++;
				pmp_addr[i].end = readl((void *)(pmp_entry + j * 4));
				sbi_printf("0x%lx\n", pmp_entry + j * 4);
				j++;
				sbi_printf("pmp_addr[%d].start: 0x%lx\n", i, pmp_addr[i].start);
				sbi_printf("pmp_addr[%d].end:   0x%lx\n", i, pmp_addr[i].end);
			}
			for (int i = 0; i < 9; i++) {
				pmp_attr[i] = readl((void *)(pmp_cfg + i * 4));
				sbi_printf("0x%lx\n", pmp_cfg + i * 4);
				sbi_printf("pmp_attr[%d]:    0x%lx\n", i, pmp_attr[i]);
			}
		}

		if (sub_revision == 3)
			c910_regs.msmpr     = csr_read(CSR_MSMPR);
		c910_regs.mcor     = csr_read(CSR_MCOR);
		c910_regs.mhcr     = csr_read(CSR_MHCR);
		c910_regs.mccr2    = csr_read(CSR_MCCR2);
		c910_regs.mhint    = csr_read(CSR_MHINT);
		c910_regs.mxstatus = csr_read(CSR_MXSTATUS);
	} else {
		/* Store to other core */
		if (sub_revision < 3) {
			csr_write(CSR_PMPADDR0, c910_regs.pmpaddr0);
			csr_write(CSR_PMPADDR1, c910_regs.pmpaddr1);
			csr_write(CSR_PMPADDR2, c910_regs.pmpaddr2);
			csr_write(CSR_PMPADDR3, c910_regs.pmpaddr3);
			csr_write(CSR_PMPADDR4, c910_regs.pmpaddr4);
			csr_write(CSR_PMPADDR5, c910_regs.pmpaddr5);
			csr_write(CSR_PMPADDR6, c910_regs.pmpaddr6);
			csr_write(CSR_PMPADDR7, c910_regs.pmpaddr7);
			csr_write(CSR_PMPCFG0, c910_regs.pmpcfg0);
		} else if (sub_revision == 3) {
			sbi_printf("##############################\n");
			for (int i = 0, j = 0; i < 32; i++) {
				writel(pmp_addr[i].start, (void *)(pmp_entry + j * 4));
				sbi_printf("0x%lx\n", pmp_entry + j * 4);
				j++;
				writel(pmp_addr[i].end, (void *)(pmp_entry + j * 4));
				sbi_printf("0x%lx\n", pmp_entry + j * 4);
				j++;
				sbi_printf("pmp_addr[%d].start: 0x%lx\n", i, pmp_addr[i].start);
				sbi_printf("pmp_addr[%d].end:   0x%lx\n", i, pmp_addr[i].end);
			}
			for (int i = 0; i < 9; i++) {
				writel(pmp_attr[i], (void *)(pmp_cfg + i * 4));
				sbi_printf("0x%lx\n", pmp_cfg + i * 4);
				sbi_printf("pmp_attr[%d]:    0x%lx\n", i, pmp_attr[i]);
			}
		}

		if (sub_revision == 3)
			csr_write(CSR_MSMPR, c910_regs.msmpr);
		csr_write(CSR_MCOR, c910_regs.mcor);
		csr_write(CSR_MHCR, c910_regs.mhcr);
		csr_write(CSR_MHINT, c910_regs.mhint);
		csr_write(CSR_MXSTATUS, c910_regs.mxstatus);
	}

	spin_unlock(&init_lock);

	return 0;
}

static void c910_delegate_more_traps()
{
	unsigned long exceptions = csr_read(CSR_MEDELEG);

	/* Delegate 0 ~ 7 exceptions to S-mode */
	exceptions |= ((1U << CAUSE_MISALIGNED_FETCH) | (1U << CAUSE_FETCH_ACCESS) |
		(1U << CAUSE_ILLEGAL_INSTRUCTION) | (1U << CAUSE_BREAKPOINT) |
		(1U << CAUSE_MISALIGNED_LOAD) | (1U << CAUSE_LOAD_ACCESS) |
		(1U << CAUSE_MISALIGNED_STORE) | (1U << CAUSE_STORE_ACCESS));

	csr_write(CSR_MEDELEG, exceptions);
}

static int c910_final_init(bool cold_boot)
{
	c910_delegate_more_traps();

	return 0;
}

static int c910_irqchip_init(bool cold_boot)
{
	/* Delegate plic enable into S-mode */
	writel(C910_PLIC_DELEG_ENABLE,
		(void *)c910_regs.plic_base_addr + C910_PLIC_DELEG_OFFSET);

	return 0;
}

static int c910_ipi_init(bool cold_boot)
{
	int rc;

	if (cold_boot) {
		clint.addr = c910_regs.clint_base_addr;
		rc = clint_cold_ipi_init(&clint);
		if (rc)
			return rc;
	}

	return clint_warm_ipi_init();
}

static int c910_timer_init(bool cold_boot)
{
	int ret;

	if (cold_boot) {
		clint.addr = c910_regs.clint_base_addr;
		ret = clint_cold_timer_init(&clint, NULL);
		if (ret)
			return ret;
	}

	return clint_warm_timer_init();
}

static int c910_system_reset(u32 type)
{
	asm volatile ("ebreak");
	return 0;
}

int c910_hart_start(u32 hartid, ulong saddr)
{
	if (!need_set_cpu)
		return 0;

	if (sub_revision < 3) {
		csr_write(CSR_MRVBR, FW_TEXT_START);
		csr_write(CSR_MRMR, csr_read(CSR_MRMR) | (1 << hartid));
	} else if (sub_revision == 3) {
		int val;

		sbi_printf("release other cores:\n");
		sbi_printf("0x%x ---> 0x%lx\n", readl((void *)mrmr) | (1 << (hartid + 1)), mrmr);
		sbi_printf("0x%lx ---> 0x%lx\n", (u64)FW_TEXT_START & 0xffffffff, (mrvbr + 8 * hartid));
		sbi_printf("0x%lx ---> 0x%lx\n", (u64)FW_TEXT_START >> 32, (mrvbr + 4 + 8 * hartid));

		writel((u64)FW_TEXT_START & 0xffffffff, (void *)(mrvbr + 8 * hartid));
		writel((u64)FW_TEXT_START >> 32,        (void *)(mrvbr + 4 + 8 * hartid));
		val = readl((void *)mrmr) | (1 << (hartid + 1));
		writel(val, (void *)mrmr);

	}

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

void sbi_boot_other_core(int hartid, unsigned long saddr)
{
	sbi_hsm_hart_start(sbi_scratch_thishart_ptr(),
		hartid, saddr, 0);
}

static int c910_vendor_ext_provider(long extid, long funcid,
				unsigned long *args,
				unsigned long *out_value,
				struct sbi_trap_info *out_trap)
{
	switch (extid) {
	case SBI_EXT_VENDOR_C910_BOOT_OTHER_CORE:
		sbi_boot_other_core(args[0], args[1]);
		break;
	case SBI_EXT_VENDOR_C910_SET_PMU:
		sbi_set_pmu(args[0], args[1], args[2]);
		break;
	default:
		sbi_printf("Unsupported private sbi call: %ld\n", extid);
		asm volatile ("ebreak");
	}
	return 0;
}

const struct sbi_platform_operations platform_ops = {
	.early_init          = c910_early_init,
	.final_init          = c910_final_init,

	.irqchip_init        = c910_irqchip_init,

	.ipi_init            = c910_ipi_init,
	.ipi_send            = clint_ipi_send,
	.ipi_clear           = clint_ipi_clear,

	.timer_init          = c910_timer_init,
	.timer_event_start   = clint_timer_event_start,

#if 0
	.console_putc		= fdt_serial_putc,
	.console_getc		= fdt_serial_getc,
	.console_init		= fdt_serial_init,
#endif

	.system_reset        = c910_system_reset,

	.hart_start          = c910_hart_start,

	.vendor_ext_provider = c910_vendor_ext_provider,
};

const struct sbi_platform platform = {
	.opensbi_version     = OPENSBI_VERSION,
	.platform_version    = SBI_PLATFORM_VERSION(0x0, 0x01),
	.name                = "T-HEAD Xuantie c910",
	.features            = SBI_THEAD_FEATURES,
	.hart_count          = C910_HART_COUNT,
	.hart_stack_size     = SBI_PLATFORM_DEFAULT_HART_STACK_SIZE,
	.platform_ops_addr   = (unsigned long)&platform_ops
};
