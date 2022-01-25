#ifndef _MANGO_PLATFORM_H_
#define _MANGO_PLATFORM_H_

#define MANGO_HART_COUNT	64

#define CSR_MCOR         0x7c2
#define CSR_MHCR         0x7c1
#define CSR_MCCR2        0x7c3
#define CSR_MHINT        0x7c5
#define CSR_MHINT4       0x7ce
#define CSR_MXSTATUS     0x7c0
#define CSR_PLIC_BASE    0xfc1
#define CSR_MRMR         0x7c6
#define CSR_MRVBR        0x7c7
#define CSR_MCOUNTERWEN  0x7c9
#define CSR_MCPUID       0xfc0
#define CSR_MSMPR        0x7f3

#define MANGO_CORES_PER_CLUSTER		2
#define MANGO_MHARTID_CLUSTERID_SHIFT	2
#define MANGO_MHARTID_CLUSTERID_MASK		\
	(((1UL << 7) - 1) << MANGO_MHARTID_CLUSTERID_SHIFT)
#define MANGO_MHARTID_COREID_MASK		\
	((1UL << MANGO_MHARTID_CLUSTERID_SHIFT) - 1)

#define MANGO_CLUSTER_ID(_vhartid)	(_vhartid / MANGO_CORES_PER_CLUSTER)
#define MANGO_CORE_ID(_vhartid)		(_vhartid % MANGO_CORES_PER_CLUSTER)

#define MANGO_MTIMECMP_SIZE_PER_CLUSTER	(64 * 1024)

#endif
