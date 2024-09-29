#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <math.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <stdint.h>

#define SPI_FLASH_MAX_SIZE	0x4000000
#define DISK_PART_TABLE_ADDR	0x80000
#define BUFFER_SIZE		1024
#define UP_4K_ALIGN 		0x1000
#define NUM_PAR_PER_PART 	4

enum {
	DPT_MAGIC	= 0x55aa55aa,
};

/* disk partition table */
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

static int spi_flash_pack(int fd_spi, struct part_info *info, const char *name)
{
	int fd, i;
	unsigned char buf[BUFFER_SIZE];
	int read_len;
	int pack_size = 0;

	fd = open(name, O_RDONLY, 0);
	if (fd < 0) {
		printf("open %s failed\n", name);
		return fd;
	}

	lseek(fd_spi, info->offset, SEEK_SET);
	while ((read_len = read(fd, buf, BUFFER_SIZE)) > 0) {
		write(fd_spi, buf, read_len);
		pack_size += read_len;
	}

	close(fd);

	return pack_size;
}

int paser_and_setup_part_info(struct part_info *info,
			      const char *part_name,
			      const char *file_name,
			      uint64_t lma, int offset)
{
	struct stat file_stat;
	int len, size;
	int ret;
	const char xmr_name[] = "sg2044r_xmrig";

	memset(info, 0, sizeof(struct part_info));

	len = strlen(part_name);
	size = sizeof(info->name);
	ret = stat(file_name, &file_stat);
	if (ret || !file_stat.st_size) {
		printf("can't get file %s size %ld\n", file_name,
		       file_stat.st_size);
		return -1;
	}

	info->magic = DPT_MAGIC;
	memcpy(info->name, part_name, len > size ? size : len);

	if (!memcmp(xmr_name, part_name, len)) {
		info->offset = (offset + (UP_4K_ALIGN - 1)) & ~(UP_4K_ALIGN - 1);
	} else {
		info->offset = offset;
	}

	info->size = file_stat.st_size;
	info->lma = lma;

	printf("%s offset:0x%x size:0x%x lma:0x%lx\n",
	       info->name, info->offset,
	       info->size, info->lma);

	if (info->offset + info->size > SPI_FLASH_MAX_SIZE) {
		printf("%s too big\n", info->name);
		return -1;
	}

	return 0;
}

int main(int argc, char **argv)
{
	int part_num, offset, size, ret, i;
	int fd_spi;
	struct stat fd_statbuf;
	unsigned char raw_byte;
	char *part_name, *file_name;
	struct part_info *info;
	uint64_t lma, flash_offset;
	unsigned char zero_byte = 0;

	fd_spi = open("./spi_flash_xmr.bin", O_CREAT | O_RDWR, 0644);
	if (fd_spi < 0) {
		ret = errno;
		printf("open spi_flash failed %d\n", ret);
		return ret;
	}

	part_num = (argc - 1) / NUM_PAR_PER_PART;
	offset = DISK_PART_TABLE_ADDR + sizeof(struct part_info) * part_num;
	offset = (offset + UP_4K_ALIGN - 1) & ~(UP_4K_ALIGN - 1);
	info = malloc(sizeof(struct part_info) * part_num);
	if (info == NULL) {
		printf("failed to malloc\n");
		goto failed_pack;
	}

	for (i = 0; i < part_num; i++) {
		part_name = argv[i * NUM_PAR_PER_PART + 1];
		file_name = argv[i * NUM_PAR_PER_PART + 2];
		ret = sscanf(argv[i * NUM_PAR_PER_PART + 3], "0x%lx",
							&flash_offset);
		if (ret < 0) {
			printf("sscanf flash_offset error\n");
			goto failed_pack;
		}

		/* dtb files are placed after partition table by default */
		if (i != 0 && (strstr(part_name, "dtb") != NULL ||
				strstr(file_name, "dtb") != NULL) ) {
			flash_offset = offset;
		} else {
			if (flash_offset & (UP_4K_ALIGN - 1)) {
				printf("Flash offset needs aligned to 4KB.\n");
				flash_offset = (flash_offset + UP_4K_ALIGN - 1)
						& ~(UP_4K_ALIGN - 1);
			}

			if (offset > flash_offset) {
				printf("Flash offset overlaps with the previous file.\
					flash_offset=0x%lx\toffset=0x%x\n",
					flash_offset, offset);
				goto failed_pack;
			}

			offset = flash_offset;
		}

		ret = sscanf(argv[i * NUM_PAR_PER_PART + 4], "0x%lx", &lma);
		if (ret < 0) {
			printf("sscanf lma error\n");
			goto failed_pack;
		}

		ret = paser_and_setup_part_info(&info[i], part_name, file_name,
						lma, flash_offset);
		if (ret) {
			printf("failed to setup part info\n");
			goto failed_pack;
		}

		size = spi_flash_pack(fd_spi, &info[i], file_name);
		if (size <= 0) {
			printf("failed to pack spi flash\n");
			goto failed_pack;
		}
		offset += size;
	}

	/* write partition table */
	lseek(fd_spi, DISK_PART_TABLE_ADDR, SEEK_SET);
	write(fd_spi, info, sizeof(struct part_info) * part_num);

failed_pack:
	close(fd_spi);
	free(info);

	return ret;
}
