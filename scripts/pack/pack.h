#ifndef _PACK_H_
#define _PACK_H_

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <fcntl.h>
#include <string.h>
#include <sys/stat.h>
#include <getopt.h>

#define MAX_CONTEXT_SIZE 0x8000000
#define MAX_BUFFER_SIZE 256
#define MAX_VERSION_SIZE 16
#define OPTION_MASK 0xffffffff
#define PARTITION_TABLE_SIZE 0x1000
#define COMMAND_SHOW_PARTITION 0x00000008
#define DEFAULT_PARTITION_TABLE 0x80000

#define SELECT(sel, x) sel = (((1 << (x)) & OPTION_MASK) | (sel))
#define MASK(x) ((1 << (x)) & OPTION_MASK)
#define ALIGEN(x) ((x) & 0xfff)
#define SET_ALIGEN(x) (ALIGEN(x) ? (((x) & (~0xfff)) + 0x1000) : (x))

#define pr_err(fmt, ...) fprintf(stderr, fmt, ##__VA_ARGS__)

enum {
	OPTION_ADD = 0,
	OPTION_EXTRACT,
	OPTION_PARTNAME,
	OPTION_TABLEINFO,
	OPTION_LOADADDR,
	OPTION_FILEPATH,
	OPTION_OFFSET,
	OPTION_FIRMWARESIZE,
	OPTION_HELP,
};

enum {
	DPT_MAGIC = 0x55aa55aa,
};

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

struct part_list {
	struct part_info part;
	struct part_list *next;
};

#endif