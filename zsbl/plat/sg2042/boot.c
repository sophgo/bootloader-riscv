#define DEBUG
#include <stdio.h>
#include <timer.h>
#include <string.h>
#include <framework/module.h>
#include <framework/common.h>
#include <lib/libc/errno.h>
#include <driver/sd/sd.h>
#include <driver/io/io_sd.h>
#include <driver/io/io_flash.h>
#include <driver/io/io.h>

#include <ff.h>
#include <platform.h>
#include <memmap.h>
#include <lib/mmio.h>
#include <assert.h>
#include <of.h>
#include <smp.h>
#include <sbi/riscv_asm.h>
#include "spinlock.h"
#include "board.h"
#include <libfdt.h>
//#include <thread_safe_printf.h>

#define FILE_NUM	5
//#define ZSBL_BOOT_DEBUG
//#define ZSBL_BOOT_DEBUG_LOOP

#ifdef ZSBL_BOOT_DEBUG
void uart_putc(int ch);
void uart_puts(const char *s)
{
	while (*s) {
		uart_putc(*s++);
	}
}

static void hex2asc(const char *pdata, char *pstr, int len)
{
	char ch;
	int i, mylen;

	if(len>16)
		mylen = 16;
	else
		mylen = len;

	for(i=mylen; i>0; i--)
	{
		ch = pdata[(i-1)>>1];
		if( i%2 )
			ch &= 0xF;
		else
			ch >>= 4;
		if(ch<10)
			ch += '0';
		else
			ch += ('A'-10);
		pstr[mylen-i] = ch;

	}
	pstr[mylen] = 0;
}

void print_u32(unsigned int u32)
{
	char str[8+1];

	hex2asc((const char *)&u32, str, 8);
	uart_puts(str);
}

void print_u8(unsigned int u32)
{
	char str[2+1];

	hex2asc((const char *)&u32, str, 2);
	uart_puts(str);
}
#endif

enum {
        ID_OPENSBI = 0,
        ID_KERNEL,
        ID_RAMFS,
        ID_DEVICETREE,
        ID_MAX,
};

BOOT_FILE boot_file[ID_MAX] = {
	[ID_OPENSBI] = {
		.id = ID_OPENSBI,
		.name = "0:riscv64/fw_jump.bin",
		.addr = OPENSBI_ADDR,
	},
	[ID_KERNEL] = {
		.id = ID_KERNEL,
		.name = "0:riscv64/riscv64_Image",
		.addr = KERNEL_ADDR,
	},
	[ID_RAMFS] = {
		.id = ID_RAMFS,
		.name = "0:riscv64/initrd.img",
		.addr = RAMFS_ADDR,
	},
	[ID_DEVICETREE] = {
		.id = ID_DEVICETREE,
		.name = "0:riscv64/mango.dtb",
		.addr = DEVICETREE_ADDR,
	},
};

char *sd_img_name[FILE_NUM] = {
	"0:riscv64/fw_jump.bin",
	"0:riscv64/riscv64_Image",
	"0:riscv64/initrd.img",
	"0:riscv64/mango.dtb",
	"0:riscv64/mango_evb_v0.1.dtb",
};

char *spflash_img_name[FILE_NUM] = {
	"fw_jump.bin",
	"riscv64_Image",
	"initrd.img",
	"mango.dtb",
	"mango_evb_v0.1.dtb",
};

char *ddr_node_name[SG2042_MAX_CHIP_NUM][DDR_CHANLE_NUM] = {
	{
		"/memory@0/",
		"/memory@1/",
		"/memory@2/",
		"/memory@3/",
	}, {
		"/memory@4/",
		"/memory@5/",
		"/memory@6/",
		"/memory@7/",
	}

};

board_info sg2042_board_info;

int read_all_img(IO_DEV *io_dev)
{
	FILINFO info;

	if (io_dev->func.init()) {
		pr_err("init %s device failed\n", io_dev->type == IO_DEVICE_SD ? "sd" : "flash");
		goto umount_dev;
	}

	for (int i = 0; i < ID_MAX; i++) {
		if (io_dev->func.open(boot_file[i].name, FA_READ)) {
			pr_err("open %s failed\n", boot_file[i].name);
			goto close_file;
		}

		if (io_dev->func.get_file_info(boot_file, i, &info)) {
			pr_err("get %s info failed\n", boot_file[i].name);
			goto close_file;
		}
		boot_file[i].len = info.fsize;
		if (io_dev->func.read(boot_file, i, info.fsize)) {
			pr_err("read %s failed\n", boot_file[i].name);
			goto close_file;
		}

		if (io_dev->func.close()) {
			pr_err("close %s failed\n", boot_file[i].name);
			goto umount_dev;
		}
	}

	io_dev->func.destroy();

	return 0;

close_file:
	io_dev->func.close();
umount_dev:
	io_dev->func.destroy();

	return -1;
}

int boot_device_register()
{
	if (sd_io_device_register() || flash_io_device_register()) {
		return -1;
	}

	return 0;
}

int build_bootfile_info(int dev_num)
{
	if (dev_num == IO_DEVICE_SD) {
		for (int i = 0; i < ID_MAX; i++)
			boot_file[i].name = sd_img_name[i];
		if (mmio_read_32(BOARD_TYPE_REG) == 0x02)
			boot_file[3].name = sd_img_name[4];
	}
	else if (dev_num == IO_DEVICE_SPIFLASH) {
		for (int i = 0; i < ID_MAX; i++)
			boot_file[i].name = spflash_img_name[i];
		if (mmio_read_32(BOARD_TYPE_REG) == 0x02)
			boot_file[3].name = spflash_img_name[4];
	}
	else
		return -1;

	return 0;
}

int read_boot_file(void)
{
	IO_DEV *io_dev;
	int dev_num;

	if (boot_device_register())
		return -1;

	if ((mmio_read_32(BOOT_SEL_ADDR) & BOOT_FROM_SD_FIRST)
	    && bm_sd_card_detect()) {
		dev_num = IO_DEVICE_SD;
		pr_debug("rv boot from sd card\n");
	} else {
		dev_num = IO_DEVICE_SPIFLASH;
		pr_debug("rv boot from spi flash\n");
	}
	// dev_num = IO_DEVICE_SPIFLASH;
	build_bootfile_info(dev_num);
	io_dev = set_current_io_device(dev_num);
	if (io_dev == NULL) {
		pr_debug("set current io device failed\n");
		return -1;
	}

	if (read_all_img(io_dev)) {
		if (dev_num == IO_DEVICE_SD) {
			dev_num = IO_DEVICE_SPIFLASH;
			build_bootfile_info(dev_num);
			io_dev = set_current_io_device(dev_num);
			if (io_dev == NULL) {
				pr_debug("set current device to flash failed\n");
				return -1;
			}

			if (read_all_img(io_dev)) {
				pr_debug("%s read file failed\n",
					 dev_num == IO_DEVICE_SD ? "sd" : "flash");
				return -1;
			}

			pr_debug("%s read file ok\n", dev_num == IO_DEVICE_SD ? "sd" : "flash");
		} else {
			pr_debug("%s read file failed\n", dev_num == IO_DEVICE_SD ? "sd" : "flash");
			return -1;
		}
	} else {
		pr_debug("%s read file ok\n",
			 dev_num == IO_DEVICE_SD ? "sd" : "flash");
	}

        return 0;
}

int show_ddr_node(char *path)
{
	int len;
	int node;
	const uint64_t *p_value = NULL;

	node = fdt_path_offset((void *)boot_file[ID_DEVICETREE].addr, path);
	if (node < 0) {
		pr_err("can not find %s\n", path);
		return -1;
	}
	p_value = fdt_getprop((void *)boot_file[ID_DEVICETREE].addr, node, "reg", &len);
	if (!p_value) {
		pr_err("can not get reg\n");
		return -1;
	}
	if (len != 16) {
		pr_err("the size is error\n");
		return -1;
	}

	pr_debug("    base:0x%lx, len:0x%lx\n", fdt64_ld(&p_value[0]), fdt64_ld(&p_value[1]));

	return 0;
}

int modify_ddr_node(void)
{
	uint64_t value[2];
	int chip_num = 1;

	if (sg2042_board_info.multi_sockt_mode)
		chip_num = SG2042_MAX_CHIP_NUM;

	for (int i = 0; i < chip_num; i++) {
		pr_debug("chip%d ddr node in dtb:\n", i);
		for (int j = 0; j < DDR_CHANLE_NUM; j++) {
			value[0] = sg2042_board_info.ddr_info[i].ddr_start_base[j];
			value[1] = sg2042_board_info.ddr_info[i].chip_ddr_size[j];
			if (i == 0 && j == 0) {
				value[0] += DDR0_RESERVED;
				value[1] -= DDR0_RESERVED;
			}
			of_modify_prop((void *)boot_file[ID_DEVICETREE].addr, boot_file[ID_DEVICETREE].len,
				       sg2042_board_info.ddr_info[i].ddr_node_name[j], "reg", (void *)value,
				       sizeof(value), PROP_TYPE_U64);

			show_ddr_node(sg2042_board_info.ddr_info[i].ddr_node_name[j]);
		}
	}

	return 0;
}

int modify_chip_node(int chip_num)
{
	uint64_t mp0_status_base = chip_num * SG2040_CHIP_ADDR_SPACE + MP0_STATUS_ADDR;
	uint64_t mp0_control_base = chip_num * SG2040_CHIP_ADDR_SPACE + MP0_CONTROL_ADDR;
	uint32_t cluster_id;
	uint32_t cluster_status;
	uint32_t cpu_id;
	char cpu_node[16];

	for (int i = 0; i < SG2042_CLUSTER_PER_CHIP; i++) {
		cluster_id = mmio_read_32(mp0_status_base + (i << 3));
		cluster_status = mmio_read_32(mp0_control_base + (i << 3));
		if (cluster_status == 0) {
			for (int j = 0; j < MANGO_CORES_PER_CLUSTER; j++) {
				cpu_id = cluster_id * MANGO_CORES_PER_CLUSTER + j;
				memset(cpu_node, 0, sizeof(cpu_node));
				sprintf(cpu_node, "/cpus/cpu@%d/", cpu_id);
				of_modify_prop((void *)boot_file[ID_DEVICETREE].addr, boot_file[ID_DEVICETREE].len,
						cpu_node, "status", (void *)"dis", sizeof("dis"), PROP_TYPE_STR);

			}
		}
	}

	return 0;
}

int modify_cpu_node(void)
{
	int chip_num = 1;

	if (sg2042_board_info.multi_sockt_mode)
		chip_num = SG2042_MAX_CHIP_NUM;

	for (int i = 0; i < chip_num; i++) {
		modify_chip_node(i);
	}

	return 0;
}

int modify_dtb(void)
{
	modify_ddr_node();
	modify_cpu_node();

	return 0;
}

#define STACK_SIZE 4096

typedef struct {
	uint8_t stack[STACK_SIZE];
} core_stack;
static core_stack secondary_core_stack[CONFIG_SMP_NUM];

#ifdef ZSBL_BOOT_DEBUG
static spinlock_t print_lock = SPIN_LOCK_INITIALIZER;
volatile uint32_t core_stats[CONFIG_SMP_NUM];
volatile uint32_t *sram_point   = (uint32_t *)(0x70101d2000Ul);
volatile uint32_t *sram_sp_addr = (uint32_t *)(0x70101d3000Ul);
#endif

static void secondary_core_fun(void *priv)
{
#ifdef ZSBL_BOOT_DEBUG
	unsigned int cid = current_hartid();
	register unsigned long sp asm("sp");

	sram_point[cid] = sram_point[cid] + 0x100;
	core_stats[cid] = 0xbeef;
	__asm__ volatile("":::"memory");
	__asm__ volatile("fence rw, rw":::);

	spin_lock(&print_lock);

	sram_point[cid] = sram_point[cid] + 0x10;
	sram_sp_addr[cid] = sp;

	uart_puts("my core id : "); print_u8(cid); uart_puts("\r\n");

	spin_unlock(&print_lock);

	sram_point[cid] = sram_point[cid] + 0x10;
	core_stats[cid] = 0xface0000;
	__asm__ volatile("":::"memory");
	__asm__ volatile("fence rw, rw":::);

#ifdef ZSBL_BOOT_DEBUG_LOOP
	while(1) {
		mdelay(10000);
		sram_point[cid] = sram_point[cid] + 1;
		core_stats[cid] = core_stats[cid] + 1;
		__asm__ volatile("":::"memory");
		__asm__ volatile("fence rw, rw":::);
	}
#endif // ZSBL_BOOT_DEBUG_LOOP

#endif // ZSBL_BOOT_DEBUG

	jump_to(boot_file[ID_OPENSBI].addr, current_hartid(),
		boot_file[ID_DEVICETREE].addr);
}

int boot_next_img(void)
{
	unsigned int hartid = current_hartid();

#ifdef ZSBL_BOOT_DEBUG
	spin_lock(&print_lock);
	uart_puts("main core id : "); print_u8(hartid); uart_puts("\r\n");
	spin_unlock(&print_lock);
#endif // ZSBL_BOOT_DEBUG

	for (int i = 0; i < CONFIG_SMP_NUM; i++) {
		if (i == hartid)
			continue;
		wake_up_other_core(i, secondary_core_fun, NULL,
					&secondary_core_stack[i], STACK_SIZE);
	}

	return 0;
}

uint64_t get_ddr_size(uint64_t ddr_reg_size, int ddr_chanle)
{
	uint64_t ddr_size = 0xffUL << (ddr_chanle << 3);
	ddr_size = (ddr_size & ddr_reg_size) >> (ddr_chanle << 3);
	if (ddr_size == DDR_SIZE_ZERO)
		return 0;

	ddr_size = 1UL << (SG2042_MAX_PHY_ADDR_WIDTH - ddr_size);

	return ddr_size;
}


int build_ddr_info (int chip_num)
{
	uint64_t reg_ddr_size_base = chip_num * 0x8000000000 + DDR_SIZE_ADDR;
	uint32_t sg2042_ddr_reg_size = mmio_read_32(reg_ddr_size_base);
	uint64_t ddr_start_base = sg2042_board_info.ddr_info[chip_num].ddr_start_base[0];

	pr_debug("chip%d ddr info: raw data=0x%x, \n", chip_num, sg2042_ddr_reg_size);

	for (int i = 0; i < DDR_CHANLE_NUM; i++) {
		sg2042_board_info.ddr_info[chip_num].ddr_start_base[i] = ddr_start_base;
		sg2042_board_info.ddr_info[chip_num].chip_ddr_size[i] = get_ddr_size(sg2042_ddr_reg_size, i);
		ddr_start_base += sg2042_board_info.ddr_info[chip_num].chip_ddr_size[i];

		pr_info("    ddr%d size:0x%lx\n", i, sg2042_board_info.ddr_info[chip_num].chip_ddr_size[i]);
	}

	return 0;
}

int build_board_info(void)
{
	if (mmio_read_32(BOOT_SEL_ADDR) & MULTI_SOCKET_MODE) {
		pr_info("sg2042 work in multi socket mode\n");
		sg2042_board_info.multi_sockt_mode = 1;
	} else {
		pr_info("sg2042 work in single socket mode\n");
	}

	for (int i = 0; i < SG2042_MAX_CHIP_NUM; i++)
		for (int j = 0; j < DDR_CHANLE_NUM; j++)
			sg2042_board_info.ddr_info[i].ddr_node_name[j] = ddr_node_name[i][j];

	sg2042_board_info.ddr_info[0].ddr_start_base[0] = 0;
	sg2042_board_info.ddr_info[1].ddr_start_base[0] = 0x800000000;

	if (sg2042_board_info.multi_sockt_mode) {
		for (int i = 0; i < SG2042_MAX_CHIP_NUM; i++)
			build_ddr_info(i);
	} else {
		build_ddr_info(0);
	}

	return 0;
}

int print_banner(void)
{
	pr_info("\n\nSOPHGO ZSBL\nsg2042:v%s\n\n", ZSBL_VERSION);

	return 0;
}

int boot(void)
{
	print_banner();
	build_board_info();

	if (read_boot_file()) {
		pr_err("read boot file faile\n");
		assert(0);
	}

	if (modify_dtb()) {
		pr_err("modify dtb failed\n");
		assert(0);
	}

	if (boot_next_img()) {
		pr_err("boot next img failed\n");
		assert(0);
	}

#ifdef ZSBL_BOOT_DEBUG
	//spin_lock(&print_lock);
	uart_puts("all cores woke up\r\n");
	//spin_unlock(&print_lock);

	core_stats[current_hartid()] = 0xface0001;
	sram_point[current_hartid()] = 0x5A5A0001;
	__asm__ volatile("":::"memory");
	__asm__ volatile("fence rw, rw":::);

#ifdef ZSBL_BOOT_DEBUG_LOOP
	while(1) {
		mdelay(20000);

		//spin_lock(&print_lock);
		uart_puts(">>>\r\n");
		for (int i = 0; i < 64; i++) {
			uart_puts("core_stats[");     print_u8(i); uart_puts("] = ");
				print_u32(core_stats[i]); uart_puts("\r\n");
			uart_puts("   sram_point[");  print_u8(i); uart_puts("]   = ");
				print_u32(sram_point[i]); uart_puts("\r\n");
			uart_puts("   sram_sp_addr["); print_u8(i); uart_puts("] = ");
				print_u32(sram_sp_addr[i]); uart_puts("\r\n");
		}
		uart_puts("<<<\r\n");
		//spin_unlock(&print_lock);

		sram_point[current_hartid()] = sram_point[current_hartid()] + 1;
		core_stats[current_hartid()] = core_stats[current_hartid()] + 1;
		__asm__ volatile("":::"memory");
		__asm__ volatile("fence rw, rw":::);
	}
#endif // ZSBL_BOOT_DEBUG_LOOP

#endif // ZSBL_BOOT_DEBUG

	jump_to(boot_file[ID_OPENSBI].addr, current_hartid(),
		boot_file[ID_DEVICETREE].addr);

	return 0;
}
test_case(boot);
