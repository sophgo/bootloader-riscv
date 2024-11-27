#ifndef __COMMON_H__
#define __COMMON_H__

#define ARRAY_SIZE(array)	(sizeof(array) / sizeof(array[0]))

enum {
	COMP_TYPE_APP = 0,
	COMP_TYPE_LOADER = 1,
	COMP_TYPE_I2C_UPGRADER = 2,
	COMP_TYPE_UART_UPGRADER = 3,
};

struct efie {
	uint32_t	offset;
	uint32_t	length;
	uint8_t		checksum[16];
	uint8_t		is_checked;
	uint8_t		type;
	uint8_t		padding[102];
} __attribute__((packed));

struct fwinfo {
	uint8_t		magic[4];
	uint8_t		type;
	uint8_t		mcu_family;
	uint8_t		r0[2];
	uint32_t	timestamp;
	uint8_t		r1[100];
} __attribute__((packed));

struct comp {
	const char *file;
	unsigned long size;
	unsigned char *buf;
	struct efie efie;
};

enum {
	STM32L0 = 0,
	GD32E50,
};

void checksum(void *out, void *in, unsigned long len);
int load_file(struct comp *comp, const char *file);
void unload_file(struct comp *comp);
int store_file(void *buf, unsigned long size, const char *file);
void print_efie(struct efie *efie);
int get_firmware_type(char *name);
void init_fwinfo(struct fwinfo *fwinfo);
int get_mcu_family(char *name);

#endif
