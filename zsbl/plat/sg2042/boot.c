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

#include <of.h>

enum {
        ID_OPENSBI = 0,
        ID_KERNEL,
        ID_RAMFS,
        ID_DEVICETREE,
        ID_MAX,
};

typedef struct boot_file {
        uint32_t id;
        char *name;
        uint64_t addr;
        int len;
}BOOT_FILE;

BOOT_FILE boot_file[ID_MAX] = {
        [ID_OPENSBI] = {
                .id = ID_OPENSBI,
                .name = "0:riscv/mytest.dtb",
                .addr = OPENSBI_ADDR,
        },
        [ID_KERNEL] = {
                .id = ID_KERNEL,
                .name = "Image",
                .addr = KERNEL_ADDR,
        },
        [ID_RAMFS] = {
                .id = ID_RAMFS,
                .name = "initrd.img",
                .addr = RAMFS_ADDR,
        },
        [ID_DEVICETREE] = {
                .id = ID_DEVICETREE,
                .name = "mango.dtb",
                .addr = DEVICETREE_ADDR,
        },
};
uint8_t temp_buf[1024];
int32_t g_filelen;
int read_all_img(IO_DEV *io_dev)
{
	FILINFO info;

	if (io_dev->func.init()) {
		pr_debug("init sd device failed\n");
		goto umount_dev;
	}

	for (int i = 0; i < 1; i++) {
		if (io_dev->func.open(boot_file[i].name, FA_READ)) {
			pr_debug("open %s failed\n", boot_file[i].name);
			goto close_file;
		}

		if (io_dev->func.get_file_info(boot_file[i].name, &info)) {
			pr_debug("get %s info failed\n", boot_file[i].name);
			goto close_file;
		}
		g_filelen = info.fsize;
		if (io_dev->func.read((uint64_t)temp_buf, info.fsize)) {
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
int boottest(void)
{
	IO_DEV *io_dev;
	int dev_num;

	if (boot_device_register())
		return -1;

	// if ((mmio_read_32(BOOT_SEL_ADDR) & BOOT_FROM_SD_FIRST)
	//     && bm_sd_card_detect()) {
	// 	dev_num = IO_DEVICE_SD;
	// } else {
	// 	dev_num = IO_DEVICE_SPIFLASH;
	// }
	dev_num = IO_DEVICE_SD;

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

		} else {
			pr_debug("%s read file failed\n",
				 dev_num == IO_DEVICE_SD ? "sd" : "flash");
			return -1;
		}
	} else {
		pr_debug("%s read file ok\n",
			 dev_num == IO_DEVICE_SD ? "sd" : "flash");
	}
	of_test(temp_buf);
	while (1) {
		pr_info("Hello BM1686 A53 System\n");
		mdelay(1000);
	}
        return 0;
}
// test_case(boottest);
