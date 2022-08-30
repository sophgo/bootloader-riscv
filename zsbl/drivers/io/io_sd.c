#define DEBUG
#include <stdio.h>
#include <framework/common.h>

#include <driver/io/io.h>
#include <driver/sd/sd.h>

static int sd_device_init(void);
static int sd_device_open(char *name, uint8_t mode);
static int sd_device_read(uint64_t buf, uint64_t len);
static int sd_device_get_file_info(char *name, FILINFO *info);
static int sd_device_close(void);
static int sd_device_destroy(void);

static IO_DEV sd_io_device = {
        .type = IO_DEVICE_SD,
        .func = {
                .init = sd_device_init,
                .open = sd_device_open,
                .read = sd_device_read,
		.close = sd_device_close,
		.get_file_info = sd_device_get_file_info,
		.destroy = sd_device_destroy,
        },
};
static int sd_device_init(void)
{
	FRESULT f_ret;
	if (!bm_sd_init(SD_USE_PIO)) {
		pr_debug("sd card init ok\n");

		f_ret = f_mount(&sd_io_device.SDC_FS, "0:", 1);
		if (f_ret == FR_OK) {
			pr_debug("sd card mount ok\n");
		} else {
			pr_debug("sd card mount failed\n");
			return -1;
		}

		return 0;
	}

	return -1;
}

static int sd_device_destroy(void)
{
	FRESULT f_ret;

	f_ret = f_unmount("0:");
	if (f_ret == FR_OK) {
		pr_debug("unmount sd ok\n");
		return 0;
	}

	return -1;
}

static int sd_device_open(char *name, uint8_t mode)
{
	FRESULT f_ret;
	f_ret = f_open(&sd_io_device.fp, name, mode);
	if (f_ret == FR_OK) {
		pr_debug("open %s ok\n", name);
		return 0;
	} else {
		pr_debug("open %s failed\n", name);
		return -1;
	}
}

static int sd_device_read(uint64_t buf, uint64_t len)
{
	FRESULT ret;
	unsigned int rd_num;

	ret = f_read(&sd_io_device.fp, (void *)buf, len, &rd_num);
	if (ret == FR_OK) {
		pr_info("read %d bytes\n", rd_num);
		return 0;
	} else {
		pr_info("read failed %d\n", ret);
		return -1;
	}
}

static int sd_device_close(void)
{
	FRESULT f_ret;
	f_ret = f_close(&sd_io_device.fp);
	if (f_ret == FR_OK) {
		pr_debug("close file ok\n");
		return 0;
	} else {
		pr_debug("close file failed\n");
		return -1;
	}
}

static int sd_device_get_file_info(char *name, FILINFO *info)
{
	FRESULT f_ret;

	f_ret = f_stat(name, info);
	if (f_ret == FR_OK) {
		pr_debug("%s file size is %d\n", name, info->fsize);
		return 0;
	} else {
		pr_debug("get file info failed\n");
		return -1;
	}
}

int sd_io_device_register(void)
{
	if (io_device_register(IO_DEVICE_SD, &sd_io_device)) {
		pr_debug("sd io register faild\n");
		return -1;
	}

	return 0;
}

