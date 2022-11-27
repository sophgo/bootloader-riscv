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
//#include <thread_safe_printf.h>

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
uint8_t temp_buf[1024];
int32_t g_filelen;
int read_all_img(IO_DEV *io_dev)
{
	FILINFO info;

	if (io_dev->func.init()) {
		pr_debug("init %s device failed\n", io_dev->type == IO_DEVICE_SD ? "sd" : "flash");
		goto umount_dev;
	}

	for (int i = 0; i < ID_MAX; i++) {
		if (io_dev->func.open(boot_file[i].name, FA_READ)) {
			pr_debug("open %s failed\n", boot_file[i].name);
			goto close_file;
		}

		if (io_dev->func.get_file_info(boot_file, i, &info)) {
			pr_debug("get %s info failed\n", boot_file[i].name);
			goto close_file;
		}
		g_filelen = info.fsize;
		if (io_dev->func.read(boot_file, i, info.fsize)) {
			pr_debug("read %s failed\n", boot_file[i].name);
			goto close_file;
		}

		// pr_debug("%s:%s\n", boot_file[i].name, temp_buf);

		if (io_dev->func.close()) {
			pr_debug("close %s failed\n", boot_file[i].name);
			goto umount_dev;
		}
	}

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
	// dev_num = IO_DEVICE_SD;

	io_dev = set_current_io_device(dev_num);
	if (io_dev == NULL) {
		pr_debug("set current io device failed\n");
		return -1;
	}

	if (read_all_img(io_dev)) {
		if (dev_num == IO_DEVICE_SD) {
			dev_num = IO_DEVICE_SPIFLASH;
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

int modify_dtb(void)
{

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

int boottest(void)
{
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
test_case(boottest);
