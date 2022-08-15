#ifndef __ARCH_H__
#define __ARCH_H__

#ifndef __ASSEMBLER__

#include <stdint.h>
#include <stdbool.h>
#include <riscv_asm.h>

typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;
typedef __uint128_t uint128_t;

#define readl(a)	(*(volatile u32 *)(a))

#define writel(v, a)	(*(volatile u32 *)(a) = (v))

#ifdef CONFIG_SMP
#error "smp not supported yet"
#endif

#endif

#endif
