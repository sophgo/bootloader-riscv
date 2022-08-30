#include <arch.h>
#include <smp.h>
	.section .vector, "ax"
	.global _start
_start:
	/* for eda simulation */
	add     x0,  zero, zero
	add     x1,  zero, zero
	add     x2,  zero, zero
	add     x3,  zero, zero
	add     x4,  zero, zero
	add     x5,  zero, zero
	add     x6,  zero, zero
	add     x7,  zero, zero
	add     x8,  zero, zero
	add     x9,  zero, zero
	add     x10, zero, zero
	add     x11, zero, zero
	add     x12, zero, zero
	add     x13, zero, zero
	add     x14, zero, zero
	add     x15, zero, zero
	add     x16, zero, zero
	add     x17, zero, zero
	add     x18, zero, zero
	add     x19, zero, zero
	add     x20, zero, zero
	add     x21, zero, zero
	add     x22, zero, zero
	add     x23, zero, zero
	add     x24, zero, zero
	add     x25, zero, zero
	add     x26, zero, zero
	add     x27, zero, zero
	add     x28, zero, zero
	add     x29, zero, zero
	add     x30, zero, zero
	add     sp,  zero, zero

#ifdef CONFIG_SUPPORT_SMP
	la	t0, smp_context
	csrr	t1, mhartid
	slli	t1, t1, SMP_CONTEXT_SIZE_SHIFT
	add	t0, t0, t1
	li	t1, SMP_CONTEXT_SIZE
clean_smp_context:
	beqz	t1, clean_smp_context_done
	add	t2, t0, t1
	sd	zero, (t2)
	addi	t1, t1, -8
	j	clean_smp_context
#endif
clean_smp_context_done:
	la	a0, smp_boot_spin_lock
	li	t0, MAIN_BOOT_CORE
again:
	ld	t1, (a0)
	bnez	t1, again
	amoswap.w.aq	t1, t0, (a0)
	bnez	t1, again

	la	a1, main_boot_core
	ld	t1, (a1)
	bnez	t1, poll_core
	sd	t0, (a1)

	amoswap.w.rl	x0, x0, (a0)


1:
	/* setup stack */
	la	t0, __ld_stack_top
	add	sp, zero, t0
#ifndef CONFIG_TARGET_EMULATOR
	/* emulator can force all memory to 0 after platform reset */
	/* so clean bss is not needed */
	jal	clear_bss
#endif
	jal	load_data
	jal	system_init
	jal	__libc_init_array
	jal	main
	jal	_exit
_end:
	wfi
	beqz	zero, _end

poll_core:
	amoswap.w.rl	x0, x0, (a0)

not_support_smp:
#ifndef CONFIG_SUPPORT_SMP
	wfi
	beqz	zero, not_support_smp
#else
secondary_core_poll:
	la	t0, secondary_core_runtime_address
	ld	t1, (t0)
	bnez	t1, release_core_run

	la	t0, smp_context
	csrr	t1, mhartid
	slli	t1, t1, SMP_CONTEXT_SIZE_SHIFT
	add	t1, t0, t1
	add	t2, t1, SMP_CONTEXT_FN_OFFSET
	add	t3, t1, SMP_CONTEXT_SP_OFFSET
	add	t4, t1, SMP_CONTEXT_PRIV_OFFSET
	ld	a0, (t4)
	ld	t5, (t3)
	add	t3, t1, SMP_CONTEXT_STATCKSIZE_OFFSET
	ld	t6, (t3)
	add	sp, t6, t5
	ld	t5, (t2)
	bnez	t5, mul_core_wake_up
	j	secondary_core_poll
release_core_run:
	jalr	t1
	j	secondary_core_poll
mul_core_wake_up:
	jalr	t5
	la	t0, smp_context
	csrr	t1, mhartid
	slli	t1, t1, SMP_CONTEXT_SIZE_SHIFT
	add	t1, t0, t1
	add	t1, t1, SMP_CONTEXT_FN_OFFSET
	sd	zero, (t1)
	j	secondary_core_poll
#endif

.align 3
smp_boot_spin_lock:
.dword 0
main_boot_core:
.dword 0
