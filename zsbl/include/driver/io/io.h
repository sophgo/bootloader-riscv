#ifndef __IO_H__
#define __IO_H__

#include <ff.h>

enum {
        IO_DEVICE_SD = 0,
        IO_DEVICE_SPIFLASH,
        IO_DEVICE_MAX,
};

typedef struct {
	int (*init)(void);
	int (*open)(char *name, uint8_t flags);
	int (*read)(uint64_t buf, uint64_t len);
	int (*close)(void);
	int (*get_file_info)(char *name, FILINFO *info);
	int (*destroy)(void);

}io_funcs;

typedef struct {
	uint32_t type;
	io_funcs func;

	FATFS SDC_FS;
	FIL fp;

}IO_DEV;

int io_device_register(uint32_t dev_num, IO_DEV *dev);
IO_DEV *set_current_io_device(uint32_t dev_num);

#endif