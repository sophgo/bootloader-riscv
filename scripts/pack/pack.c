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
	DPT_MAGIC	= 0x55aa55aa,
};
#define UP_4K_ALIGN 0x1000
#define BUFFER_SIZE 1024
#define OUTPUT "firmware.bin"

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

int paser_and_setup_part_info(struct part_info *info,
			      const char *part_name,
			      const char *file_name,
			      uint64_t lma, int offset)
{
	struct stat file_stat;
	int len, size;
	int ret;
	const char xmr_name[] = "mango_xmrig";
	const char xmr_bak_name[] = "xmr_app_bak";

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
	} else if (!memcmp(xmr_bak_name, part_name, len)) {
		info->offset = (offset + (UP_4K_ALIGN - 1)) & ~(UP_4K_ALIGN - 1);
	} else {
		info->offset = offset;
	}

	info->size = file_stat.st_size;
	info->lma = lma;

	printf("%s offset:0x%x size:0x%x lma:0x%lx\n",
	       info->name, info->offset,
	       info->size, info->lma);

	// if (info->offset + info->size > SPI_FLASH_MAX_SIZE) {
	// 	printf("%s too big\n", info->name);
	// 	return -1;
	// }

	return 0;
}
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

int pack_v3(int argc, char *argv[]){

	char * __attribute__((unused)) firmware_name = "unknown_firmware";
	uint32_t firmware_size;
	ezxml_t p,comp;
	char *file=argv[1];
	printf("%s\n",argv[1]);
	unsigned int comp_count;
	int fd,ret,size;
	// struct part_info *com_part;

	ezxml_t firmware=ezxml_parse_file(file);
	if (strcmp(firmware->name, "firmware")) {
		printf("not a valid layout file\n");
		return -1;
	}
	p=ezxml_child(firmware,"name");
	firmware_name=p->txt;
	p=ezxml_child(firmware,"size");
	firmware_size=(uint32_t)strtoul(p->txt,NULL,16);

	ezxml_t efie;
	uint32_t efie_offset,efie_size;
	efie=ezxml_child(firmware,"efie");
	p=ezxml_child(efie,"offset");
	efie_offset=strtol(p->txt,NULL,16);
	p=ezxml_child(efie,"size");
	efie_size=strtol(p->txt,NULL,0);

	fd = open(OUTPUT, O_CREAT | O_RDWR | O_TRUNC, 0644);
	ezxml_t f;
	uint32_t f_offset;
	#ifdef SG2042
		f=ezxml_child(firmware,"fip");
		p=ezxml_child(f,"offset");
		f_offset=(uint32_t)strtoul(p->txt,NULL,16);
		int read_len;
		unsigned char buf[BUFFER_SIZE];
		lseek(fd, f_offset, SEEK_SET);
		while ((read_len = read(fd, buf, BUFFER_SIZE)) > 0) {
			write(fd, buf, read_len);
		}
	#endif

	for (comp=ezxml_child(firmware,"component"),comp_count=0;comp;comp=comp->next,comp_count++){
		char *com_name=NULL, *com_file=NULL;
		unsigned int com_type;
		uint32_t com_offset;
		uint64_t com_addr;

		p=ezxml_child(comp,"name");
		com_name=p->txt;
		p=ezxml_child(comp,"file");
		com_file=p->txt;
		p=ezxml_child(comp,"offset");
		com_offset=strtol(p->txt,NULL,16);
		p=ezxml_child(comp,"loader");
		com_addr=strtol(p->txt,NULL,16);
		struct part_info info;
		ret=paser_and_setup_part_info(&info,com_name,com_file,com_addr,com_offset);
		size = spi_flash_pack(fd, &info, com_file);

		lseek(fd, efie_offset+comp_count*sizeof(struct part_info), SEEK_SET);
		write(fd, &info, sizeof(struct part_info));
	}

	return 0;
}

int main(int argc, char *argv[]){
    pack_v3(argc,argv);
    return 0;
}