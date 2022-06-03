/*
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Copyright (c) 2019 Western Digital Corporation or its affiliates.
 *
 * Authors:
 *   Anup Patel <anup.patel@wdc.com>
 */

#ifndef __SYS_CLINT_H__
#define __SYS_CLINT_H__

#include <sbi/sbi_types.h>
#include <sbi/riscv_asm.h>
struct clint_data {
	/* Public details */
#ifdef MANGO
	unsigned long msip_addr;
	unsigned long mtimecmp_addr;
#endif
	unsigned long addr;
	u32 first_hartid;
	u32 hart_count;
	bool has_64bit_mmio;
	/* Private details (initialized and used by CLINT library)*/
	u32 *ipi;
	struct clint_data *time_delta_reference;
	unsigned long time_delta_computed;
	u64 time_delta;
	u64 *time_val;
	u64 *time_cmp;
	u64 (*time_rd)(volatile u64 *addr);
	void (*time_wr)(u64 value, volatile u64 *addr);
};

void clint_ipi_send(u32 target_hart);

void clint_ipi_clear(u32 target_hart);

int clint_warm_ipi_init(void);

int clint_cold_ipi_init(struct clint_data *clint);

u64 clint_timer_value(void);

void clint_timer_event_stop(void);

void clint_timer_event_start(u64 next_event);

int clint_warm_timer_init(void);

int clint_cold_timer_init(struct clint_data *clint,
			  struct clint_data *reference);

#ifdef MANGO
static inline u64 mango_timer_value(void)
{
	return csr_read(CSR_TIME);
}

int clint_cold_ipi_init_range(int start, int end, struct clint_data *clint);
int clint_cold_timer_init_range(int start, int end,
				struct clint_data *clint,
				struct clint_data *reference);
#endif
#endif
