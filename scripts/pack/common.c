#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include <time.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>

#include <global.h>
#include <md5.h>
#include <common.h>
#include <log.h>

void checksum(void *out, void *in, unsigned long len)
{
	uint32_t *src = in;
	char *init = "*BITMAIN-SOPHON*";
	uint32_t result[4];
	memcpy(result, init, sizeof(result));
	unsigned long block = len >> 4;
	unsigned long left = len & 0xf;
	unsigned long i, j;
	for (i = 0; i < block; ++i, src += 4) {
		for (j = 0; j < 4; ++j) {
			result[j] ^= src[j];
		}
	}
	for (i = 0; i < left; ++i) {
		((uint8_t *)result)[i] ^= ((uint8_t *)src)[i];
	}
	memcpy(out, result, sizeof(result));
}

int load_file(struct comp *comp, const char *file)
{
	int fd;
	int err = -1;
	struct stat stat;

	memset(comp, 0x00, sizeof(*comp));

	comp->file = file;

	fd = open(file, O_RDONLY);
	if (fd < 0) {
		error("cannot load file %s\n", file);
		return -1;
	}

	err = fstat(fd, &stat);
	if (err < 0) {
		error("cannot stat file %s\n", file);
		goto close_file;
	}
	comp->size = stat.st_size;
	comp->buf = malloc(comp->size);
	if (comp->buf == NULL) {
		error("cannot malloc buffer for file %s\n", file);
		err = -1;
		goto close_file;
	}
	if (read(fd, comp->buf, comp->size) != comp->size) {
		error("cannot load hole file %s\n", file);
		err = -1;
		goto close_file;
	}

	checksum(comp->efie.checksum, comp->buf, comp->size);
	comp->efie.length = comp->size;

	err = 0;
close_file:
	close(fd);
	return err;
}

void unload_file(struct comp *comp)
{
	if (comp->buf)
		free(comp->buf);
}

int store_file(void *buf, unsigned long size, const char *file)
{
	int fd;
	int err = -1;

	fd = open(file, O_RDWR | O_CREAT,
		  S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP);
	if (fd < 0) {
		error("cannot open file %s\n", file);
		perror("");
		return -1;
	}

	if (write(fd, buf, size) != size) {
		error("cannot store hole file %s\n", file);
		err = -1;
		goto close_file;
	}
	err = 0;
close_file:
	close(fd);
	return err;
}

void print_efie(struct efie *efie)
{
	printf("[DEBUG]: ");
	if (efie->padding[0])
		printf("name %s ", efie->padding);
	printf("offset 0x%08x length 0x%08x checksum ",
	       efie->offset, efie->length);
	int i;
	for (i = 0; i < 16; ++i)
		printf("%02x", efie->checksum[i]);
	printf("\n");
}

#include <project.h>

struct {
	char *name;
	int id[16];
} firmware_table[] = {
	{"EVB",		{EVB, SC5}},
	{"SA5",		{SA5, SE5, SM5P, SM5S}},
	{"SC5PLUS",	{SC5PLUS}},
	{"SC5H",	{SC5H}},
	{"SC5PRO",	{SC5PRO}},
	{"SM5MINI",	{SM5ME, SM5MP, SM5MS, SM5MA}},
	{"SE5LITE",	{SE5LITE}},
	{"SC7PRO",  {SC7PRO}},
	{"BM1684XEVB", {BM1684XEVB}},
	{"SM7CUSTV1", {SM7CUSTV1}},
	{"SG2042EVB", {SG2042EVB}},
	{"SG2042REVB", {SG2042REVB}},
	{"SG2042X4", {SG2042X4}},
	{"SC7HP75",  {SC7HP75}},
	{"WOLFCLAW", {WOLFCLAW}},
	{"SM7MINI", {SM7M}},
	{"SM7MQY", {SM7MQY, SE7Q}},
	{"SE7", {SE7}},
	{"SM7MSE6M", {SM7MSE6M}},
	{"SM7G", {SM7G}},
	{"SM7M_MP_1_1", {SM7M_MP_1_1}},
	{"SM7M_MP_1_2", {SM7M_MP_1_2}},
	{"ATHENA2EVB", {ATHENA2EVB}},
	{"ATHENA2ACP", {ATHENA2ACP}},
	{"SC7FP150", {SC7FP150}},
	{"SM7_HK", {SM7_HK}},
	{"BM1690EVB", {BM1690EVB}},
	{"BM2044REVB", {BM2044REVB}},
	{"SC11FP300", {SC11FP300}},
};

const char *mcu_family[] = {"STM32L0", "GD32E50"};

int get_firmware_type(char *name)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(firmware_table); ++i) {
		if (strcasecmp(firmware_table[i].name, name) == 0)
			return firmware_table[i].id[0];
	}

	return -1;
}

int get_mcu_family(char *name)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(mcu_family); ++i) {
		if (strcasecmp(mcu_family[i], name) == 0)
			return i;
	}
	return -1;
}

void init_fwinfo(struct fwinfo *fwinfo)
{
	memset(fwinfo, 0, sizeof(struct fwinfo));
	memcpy(fwinfo->magic, "MCUF", sizeof(fwinfo->magic));
	fwinfo->timestamp = (uint32_t)time(NULL);
}
