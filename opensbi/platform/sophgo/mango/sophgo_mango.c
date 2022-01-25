#include <platform_override.h>
#include <platform.h>
#include <sbi/sbi_bitops.h>
#include <sbi/sbi_console.h>
#include <sbi_utils/fdt/fdt_helper.h>
#include <sbi_utils/fdt/fdt_domain.h>
#include <sbi_utils/fdt/fdt_helper.h>

#define PMP_CFG_R	BIT(0)
#define PMP_CFG_W	BIT(1)
#define PMP_CFG_X	BIT(2)

#define PMP_CFG_A_SHIFT	3
#define PMP_CFG_A_OFF	(0UL << PMP_CFG_A_SHIFT)
#define PMP_CFG_A_TOR	(1UL << PMP_CFG_A_SHIFT)
#define PMP_CFG_A_NA4	(2UL <<	PMP_CFG_A_SHIFT)/* not supported by c910 */
#define PMP_CFG_A_NAPOT	(3UL << PMP_CFG_A_SHIFT)

#define MANGO_PA_MAX	(1UL << 44)

void mango_setup_pmp(void)
{
       csr_write(pmpaddr0, MANGO_PA_MAX >> 2);
       csr_write(pmpcfg0, PMP_CFG_R | PMP_CFG_W | PMP_CFG_X | PMP_CFG_A_TOR);
}

void mango_setup_cpu(void)
{
	csr_write(CSR_MCOR, 0x70013);
	csr_write(CSR_MHCR, 0x11ff);
	csr_write(CSR_MHINT, 0x16e30c);
	/* enable MAEE */
	csr_write(CSR_MXSTATUS, 0x638000);
	csr_write(CSR_MCCR2, 0xe0410009);
}

void mango_setup_delegate(void)
{
	unsigned long exceptions = csr_read(CSR_MEDELEG);

	/* delegate 0 ~ 7 exceptions to S-mode */
	exceptions |= ((1U << CAUSE_MISALIGNED_FETCH) |
		       (1U << CAUSE_FETCH_ACCESS) |
		       (1U << CAUSE_ILLEGAL_INSTRUCTION) |
		       (1U << CAUSE_BREAKPOINT) |
		       (1U << CAUSE_MISALIGNED_LOAD) |
		       (1U << CAUSE_LOAD_ACCESS) |
		       (1U << CAUSE_MISALIGNED_STORE) |
		       (1U << CAUSE_STORE_ACCESS));

	csr_write(CSR_MEDELEG, exceptions);
}

/* platform final initialization. */
static int mango_final_init(bool cold_boot, const struct fdt_match *match)
{
	mango_setup_pmp();
	mango_setup_cpu();
	mango_setup_delegate();

	return 0;
}



static const struct fdt_match sophgo_mango_match[] = {
	{ .compatible = "sophgo,mango" },
	{ },
};

const struct platform_override sophgo_mango = {
	.match_table = sophgo_mango_match,
	.final_init = mango_final_init,
};
