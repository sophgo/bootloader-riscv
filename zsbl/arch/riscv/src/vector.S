#include <arch.h>

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

	csrr	t0, mhartid
	beq	t0, zero, 1f

park:
	beqz	zero, park
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

