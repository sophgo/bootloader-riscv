#include <sbi/riscv_asm.h>
#include <sbi/riscv_atomic.h>
#include <sbi/riscv_io.h>
#include <sbi/sbi_bitops.h>
#include <sbi/sbi_domain.h>
#include <sbi/sbi_error.h>
#include <sbi/sbi_hartmask.h>
#include <sbi/sbi_ipi.h>
#include <sbi/sbi_timer.h>
#include <sbi_utils/timer/mango_mtimer.h>

#include <platform.h>

static struct mango_mtimer_data *mtimer_hartid2data[SBI_HARTMASK_MAX_BITS];

#if __riscv_xlen != 32
static u64 mtimer_time_rd64(volatile u64 *addr)
{
	return readq_relaxed(addr);
}

static void mtimer_time_wr64(bool timecmp, u64 value, volatile u64 *addr)
{
	writeq_relaxed(value, addr);
}
#endif

static u64 mtimer_time_rd32(volatile u64 *addr)
{
	u32 lo, hi;

	do {
		hi = readl_relaxed((u32 *)addr + 1);
		lo = readl_relaxed((u32 *)addr);
	} while (hi != readl_relaxed((u32 *)addr + 1));

	return ((u64)hi << 32) | (u64)lo;
}

static void mtimer_time_wr32(bool timecmp, u64 value, volatile u64 *addr)
{
	writel_relaxed((timecmp) ? -1U : 0U, (void *)(addr));
	writel_relaxed((u32)(value >> 32), (void *)(addr) + 0x04);
	writel_relaxed((u32)value, (void *)(addr));
}

static u64 mtimer_value(void)
{
	return csr_read(CSR_TIME);
}

static inline void *mango_time_cmp(struct mango_mtimer_data *mt, u32 hartid)
{
	unsigned int clusterid = MANGO_CLUSTER_ID(hartid);
	unsigned int coreid = MANGO_CORE_ID(hartid);

	return (void *)(mt->mtimecmp_addr +
			clusterid * MANGO_MTIMECMP_SIZE_PER_CLUSTER +
			coreid * 8);
}

static void mtimer_event_stop(void)
{
	u32 target_hart = current_hartid();
	struct mango_mtimer_data *mt = mtimer_hartid2data[target_hart];

	/* Clear MTIMER Time Compare */
	mt->time_wr(true, -1ULL, mango_time_cmp(mt, target_hart));
}

static void mtimer_event_start(u64 next_event)
{
	u32 target_hart = current_hartid();
	struct mango_mtimer_data *mt = mtimer_hartid2data[target_hart];

	/* Program MTIMER Time Compare */
	mt->time_wr(true, next_event, mango_time_cmp(mt, target_hart));
}

static struct sbi_timer_device mtimer = {
	.name = "mango-mtimer",
	.timer_value = mtimer_value,
	.timer_event_start = mtimer_event_start,
	.timer_event_stop = mtimer_event_stop
};

int mango_mtimer_warm_init(void)
{
	u32 target_hart = current_hartid();
	struct mango_mtimer_data *mt = mtimer_hartid2data[target_hart];

	if (!mt)
		return SBI_ENODEV;

	/* Clear Time Compare */
	mt->time_wr(true, -1ULL, mango_time_cmp(mt, target_hart));

	return 0;
}

static int mango_mtimer_add_regions(unsigned long addr, unsigned long size)
{
#define MTIMER_ADD_REGION_ALIGN		0x1000
	int rc;
	unsigned long pos, end, rsize;
	struct sbi_domain_memregion reg;

	pos = addr;
	end = addr + size;
	while (pos < end) {
		rsize = pos & (MTIMER_ADD_REGION_ALIGN - 1);
		if (rsize)
			rsize = 1UL << __ffs(pos);
		else
			rsize = ((end - pos) < MTIMER_ADD_REGION_ALIGN) ?
				(end - pos) : MTIMER_ADD_REGION_ALIGN;

		sbi_domain_memregion_init(pos, rsize,
					  SBI_DOMAIN_MEMREGION_MMIO, &reg);
		rc = sbi_domain_root_add_memregion(&reg);
		if (rc)
			return rc;
		pos += rsize;
	}

	return 0;
}

int mango_mtimer_cold_init(struct mango_mtimer_data *mt)
{
	u32 i;
	int rc;

	/* Sanity checks */
	if (!mt ||
	    (mt->hart_count && !mt->mtimecmp_size) ||
	    (mt->mtimecmp_addr & (MANGO_MTIMER_ALIGN - 1)) ||
	    (mt->mtimecmp_size & (MANGO_MTIMER_ALIGN - 1)) ||
	    (mt->hart_count > MANGO_MTIMER_MAX_HARTS))
		return SBI_EINVAL;

	/* Initialize private data */
	mt->time_rd = mtimer_time_rd32;
	mt->time_wr = mtimer_time_wr32;

	/* Override read/write accessors for 64bit MMIO */
#if __riscv_xlen != 32
	if (mt->has_64bit_mmio) {
		mt->time_rd = mtimer_time_rd64;
		mt->time_wr = mtimer_time_wr64;
	}
#endif

	/* Update MTIMER hartid table */
	for (i = 0; i < mt->hart_count; i++)
		mtimer_hartid2data[i] = mt;

	/* Add MTIMER regions to the root domain */
	rc = mango_mtimer_add_regions(mt->mtimecmp_addr,
				      mt->mtimecmp_size);
	if (rc)
		return rc;

	mtimer.timer_freq = mt->mtime_freq;
	sbi_timer_set_device(&mtimer);

	return 0;
}
