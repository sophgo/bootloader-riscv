#include <stdio.h>
#include <timer.h>
#include <string.h>
#include <framework/module.h>
#include <framework/common.h>
#include <lib/libc/errno.h>

#include <spinlock.h>
#include <smp.h>
#include <sbi/riscv_asm.h>

#define STACK_SIZE 4096

static spinlock_t console_out_lock = SPIN_LOCK_INITIALIZER;

typedef struct {
	uint8_t stack[STACK_SIZE];
} core_stack;
core_stack secondary_core_stack[CONFIG_SMP_NUM];

static void secondary_core_fun(void *priv)
{
        while (1) {
		spin_lock(&console_out_lock);
		printf("hart id %u print hello world\n", current_hartid());
		spin_unlock(&console_out_lock);
		mdelay(1000);
        }
}

static int testsmp(void)
{
        unsigned int hartid = current_hartid();
        printf("main core id = %u\n", hartid);

	for (int i = 0; i < CONFIG_SMP_NUM; i++) {
		if (i == hartid)
			continue;
		wake_up_other_core(i, secondary_core_fun, NULL,
				   &secondary_core_stack[i], STACK_SIZE);
	}
        while (1) {
                spin_lock(&console_out_lock);
                printf("main core id = %u\n", current_hartid());
                spin_unlock(&console_out_lock);
                mdelay(1000);
        };

        return 0;
}

test_case(testsmp);