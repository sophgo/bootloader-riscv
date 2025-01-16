#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>

#include "ezxml/ezxml.h"
#include "ezxml/ezxml.c"

enum {
	DPT_MAGIC = 0x55aa55aa,
};

#define UP_4K_ALIGN 0x1000
#define BUFFER_SIZE 1024
#define OUTPUT "firmware.bin"
#define LOADERSIZE 20
#define VERSIONOFFSET 0x0000000
#define DATEOFFSET 0x0000100

struct part_info {
	/* disk partition table magic number */
	uint32_t magic;
	char name[32];
	uint32_t offset;
	uint32_t size;
	char reserve[4];
	/* load memory address*/
	uint64_t lma;
};

static int spi_flash_pack(int fd_spi, uint32_t offset, const char *name)
{
	int fd;
	unsigned char buf[BUFFER_SIZE];
	int read_len;
	int pack_size = 0;

	fd = open(name, O_RDONLY, 0);
	if (fd < 0)  {
		printf("open %s failed\n", name);
		return fd;
	}

	lseek(fd_spi, offset, SEEK_SET);
	while ((read_len = read(fd, buf, BUFFER_SIZE)) > 0) {
		write(fd_spi, buf, read_len);
		pack_size += read_len;
	}
	printf("write %s to flash start at 0x%x and end at 0x%X\n",name, offset, offset+pack_size);
	close(fd);

	return pack_size;
}

int spi_flash_version(int fd_spi, char* version)
{
	uint32_t ver_size;

	lseek(fd_spi, VERSIONOFFSET, SEEK_SET);
	if ((ver_size = write(fd_spi, version, strlen(version) + 1)) <= 0) {
		printf("failed to write version\n");
		return -1;
	}
	printf("write version:%s to flash start at 0x%x and end at 0x%x\n", version, VERSIONOFFSET, VERSIONOFFSET + ver_size);
	return 0;
}

int spi_flash_date(int fd_spi, char* date)
{
	uint32_t date_size;

	lseek(fd_spi, DATEOFFSET, SEEK_SET);
	if ((date_size = write(fd_spi, date, strlen(date) + 1)) <= 0) {
		printf("failed to write date\n");
		return -1;
	}
	printf("write date:%s to flash start at 0x%x and end at 0x%x\n", date, DATEOFFSET, DATEOFFSET + date_size);
	return 0;
}

int get_efie_info(ezxml_t parent, uint32_t* p_off, uint32_t* p_size)
{
	ezxml_t p = ezxml_child(parent, "efie");

	if (!p) {
		printf("failed to find efie element\n");
		return -1;
	}
	p = ezxml_child(ezxml_child(parent, "efie"), "offset");
	*p_off = strtol(p->txt, NULL, 16);
	p = ezxml_child(ezxml_child(parent, "efie"), "size");
	*p_size = strtol(p->txt, NULL, 0);
	return 0;
	// printf("get the efie partion offset: 0x%x size: %d\n",*p_off,*p_size);
}

int get_component_info(ezxml_t parent, struct part_info *info, int *flag)
{
	char* p_name;
	uint32_t magic, p_offset, p_size;
	int len, size, ret;
	uint64_t p_lma;
	ezxml_t p;

	memset(info, 0, sizeof(struct part_info));
	info->magic = DPT_MAGIC;

	//add offset info
	p = ezxml_child(parent, "offset");
	p_offset = strtoul(p->txt, NULL, 16);
	info->offset = p_offset;

	//add name info
	p = ezxml_child(parent, "name");
	p_name = p->txt;
	len = strlen(p_name);
	size = sizeof(info->name);
	memcpy(info->name, p_name, len > size ? size : len);
	if (!strcmp(p_name, "fip.bin")) {
		// printf("skip %s info\n",p_name);
		*flag = 1;
		return 0;
	}

	//add size info
	struct stat file_stat;
	p = ezxml_child(parent, "size");
	p_size = strtoul(p->txt, NULL, 0);
	ret = stat(p_name, &file_stat);
	if (ret || file_stat.st_size != p_size)  {
		printf("failed to get file %s size or size: %ld not equal size from xml:%d\n", p_name,
		       file_stat.st_size, p_size);
		return -1;
	}
	info->size = file_stat.st_size;

	//add loader info
	p = ezxml_child(parent, "loader");
	p_lma = strtoul(p->txt, NULL, 16);
	info->lma = p_lma;

	return 0;
}

int main(int argc, char *argv[])
{
	char * __attribute__((unused)) firmware_name = "firmware";
	char *firmware_version, *firmware_date;
	ezxml_t p, comp;
	char *file = argv[1];
	unsigned int comp_count = 0;
	int fd, ret, fd_fip, flag;
	uint32_t efie_offset,efie_size;

	ezxml_t firmware = ezxml_parse_file(file);
	if (strcmp(firmware->name, "firmware")) {
		printf("failed: %s is not a valid layout file\n", file);
		return -1;
	}
	p = ezxml_child(firmware, "name");
	firmware_name = p->txt;

	p = ezxml_child(firmware, "version");
	firmware_version = p->txt;
	if (strlen(firmware_version) + 1> LOADERSIZE) {
		printf("failed: version number is too long, check the name length limit\n");
		return -1;
	}

	p = ezxml_child(firmware, "date");
	firmware_date = p->txt;
	if (strlen(firmware_date) + 1 > LOADERSIZE) {
		printf("failed: date size is too big, check the name length limit\n");
		return -1;
	}

	fd = open(OUTPUT, O_CREAT | O_RDWR | O_TRUNC, 0644);
	if (fd == -1) {
		printf("failed to open %s\n",OUTPUT);
		return -1;
	}

	if (ret = spi_flash_version(fd, firmware_version)) {
		printf("failed to get version\n");
		goto failed_pack;
	}

	if (ret = spi_flash_date(fd, firmware_date)) {
		printf("failed to get date\n");
		goto failed_pack;
	}

	if (ret = get_efie_info(firmware, &efie_offset, &efie_size)) {
		printf("failed to get efie info\n");
		goto failed_pack;
	}

	for (comp = ezxml_child(firmware, "component"); comp; comp = comp->next) {
		struct part_info info;

		flag = 0;
		if (ret = get_component_info(comp, &info, &flag)) {
			goto failed_pack;
		}
		if (!flag) {
			lseek(fd, efie_offset + comp_count * sizeof(struct part_info), SEEK_SET);
			write(fd, &info, sizeof(struct part_info));
			// printf("wtite %s info to the %dth partion table at 0x%lx\n",info.name,comp_count,
			// 									efie_offset+comp_count*sizeof(struct part_info));
			comp_count++;
		}
		spi_flash_pack(fd, info.offset, info.name);
	}

failed_pack:
	close(fd);
	return ret;
}

