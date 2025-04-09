#include "pack.h"

static const char *optstring = "aet:l:f:p:o:s:h";
static const struct option longopts[] = {
	{"add", no_argument, NULL, 'a'},
	{"extract", no_argument, NULL, 'e'},
	{"table", required_argument, NULL, 't'},
	{"loader", required_argument, NULL, 'l'},
	{"file", required_argument, NULL, 'f'},
	{"partition", required_argument, NULL, 'p'},
	{"offset", required_argument, NULL, 'o'},
	{"size", required_argument, NULL, 's'},
	{"help", no_argument, NULL, 'h'},
	{NULL, 0, NULL, 0}
};

static uint8_t *load_context(int fd, uint32_t size)
{
	uint8_t *context;
	uint32_t rlen;
	
	context = (uint8_t *)malloc(MAX_CONTEXT_SIZE);
	if (!context) {
		printf("Memory error: allocate memory for firmware context failed\n");
		return NULL;
	}
	rlen = read(fd, context, MAX_CONTEXT_SIZE);
	while (rlen < size)
		rlen += read(fd, context + rlen, size - rlen);
	if (rlen != size) {
		printf("Read error: the bytes %d read from firmware not equal file size %d\n",
				rlen, size);
		return NULL;
	}
	return context;
}

static struct part_list *merge(struct part_list *left, struct part_list *right)
{
	struct part_list *cur;
	struct part_list head;

	cur = &head;
	while (left && right) {
		if (left->part.offset < right->part.offset) {
			cur->next = left;
			left = left->next;
		} else {
			cur->next = right;
			right = right->next;
		}
		cur = cur->next;
	}
	cur->next = left ? left : right;

	return head.next;
}

static struct part_list *merge_sort(struct part_list *head)
{
	struct part_list *slow, *fast;
	struct part_list *mid;

	if (!head || !head->next)
		return head;
	slow = head;
	fast = slow->next;
	while (fast && fast->next) {
		slow = slow->next;
		fast = fast->next->next;
	}
	mid = slow->next;
	slow->next = NULL;

	return merge(merge_sort(head), merge_sort(mid));
} 

/* generate the partition list and reorder the members */
static struct part_list *gen_table(uint8_t *context, uint32_t tab_off)
{
	struct part_list *next = NULL, *node = NULL;
	struct part_info *temp;
	int i = 0;

	temp = (struct part_info *)(context + tab_off);
	while (temp[i].magic == DPT_MAGIC) {
		node = (struct part_list *)malloc(sizeof(struct part_list));
		if (!node) {
			printf("Memory error: allocate memory for partition failed\n");
			return NULL;
		}
		memcpy(&node->part, &temp[i], sizeof(struct part_list));
		node->next = next;
		next = node;
		i++;
	}
	return merge_sort(node);
}

static int check_partition_name(struct part_list *part_head, const char *name)
{
	struct part_list *cur = part_head;

	while (cur) {
		if (strcmp(name, cur->part.name) == 0) {
			printf("Param error: partition name %s already exist\n", name);
			return -1;
		}
		cur = cur->next;
	}
	return 0;
}

static void init_partition(struct part_list *new_part, const char *name, uint32_t offset,
			uint32_t size, uint64_t lma)
{
	new_part->part.magic = DPT_MAGIC;
	strcpy(new_part->part.name, name);
	new_part->part.offset = offset;
	new_part->part.size = size;
	new_part->part.lma = lma;
}

static struct part_list *update_table(struct part_list *part_head, const char *part_name,
			uint32_t offset, uint32_t size, uint64_t lma)
{
	struct part_list *pre, *cur;
	struct part_list *new_part = NULL;
	struct part_list dummy;

	if (!part_name)
		return part_head;

	pre = &dummy;
	new_part = (struct part_list *)malloc(sizeof(struct part_list));
	new_part->next = NULL;
	init_partition(new_part, part_name, offset, size, lma);

	cur = part_head;
	pre->next = cur;
	if (!cur)
		return new_part;
	while (cur) {
		if (offset < cur->part.offset)
			break;
		pre = cur;
		cur = cur->next;
	}
	new_part->next = pre->next;
	pre->next = new_part;

	return dummy.next;
}

static int check_one_border(struct part_list *cur, uint32_t offset, uint32_t size)
{
	if (((offset + size) < cur->part.offset) ||
		(offset > (cur->part.offset + cur->part.size)))
		return 0;

	return -1;
}

static int check_borders(struct part_list *part_head, uint32_t offset, uint32_t size,
			uint32_t tab_off)
{
	struct part_list *cur = part_head;
	if (ALIGEN(offset)) {
		printf("Address error: offset is not aligen\n");
		return -1;
	}
	while (cur) {
		if (check_one_border(cur, offset, size))
			return -1;
		cur = cur->next;
	}
	if (((offset + size) < tab_off) || offset >= (SET_ALIGEN(tab_off + PARTITION_TABLE_SIZE)))
		return 0;

	return -1;
}

static struct part_list *auto_update_table(struct part_list *part_head, const char *part_name,
			uint32_t tab_off, uint32_t *offset, uint32_t size, uint64_t lma)
{
	struct part_list *cur = part_head;
	uint32_t off = 0;

	off = SET_ALIGEN(tab_off + PARTITION_TABLE_SIZE);
	while (check_borders(cur, off, size, tab_off)) {
		off = SET_ALIGEN(cur->part.offset + cur->part.size);
		cur = cur->next;
		while (off < tab_off) {
			off = SET_ALIGEN(cur->part.offset + cur->part.size);
			cur = cur->next;
		}
	}
	part_head = update_table(part_head, part_name, off, size, lma);
	*offset = off;

	return part_head;
}

static uint32_t update_context(uint8_t *context, struct part_list *part_head,
			uint32_t tab_off, uint8_t *temp, uint32_t offset, uint32_t size)
{
	uint8_t *cur_ptr;
	uint32_t total_size;
	struct part_list *cur, *last = NULL;

	cur_ptr = context + tab_off;
	cur = part_head;
	while (cur) {
		memcpy(cur_ptr, &cur->part, sizeof(struct part_info));
		last = cur;
		cur = cur->next;
		cur_ptr += sizeof(struct part_info);
	}

	cur_ptr = context + offset;
	memcpy(cur_ptr, temp, size);
	if (last)
		total_size = (last->part.offset + last->part.size) > (tab_off + PARTITION_TABLE_SIZE) ?
				(last->part.offset + last->part.size) : (tab_off + PARTITION_TABLE_SIZE);
	else
		total_size = (offset + size);

	return total_size;
}

static void flush_context(int fd, uint8_t *context, uint32_t size)
{
	int wlen;

	lseek(fd, 0, SEEK_SET);
	write(fd, context, size);
}

static int extract_context(uint8_t *context, struct part_list *part_head, const char *part_name, int fd)
{
	struct part_list *cur;

	cur = part_head;
	while (cur) {
		if (strcmp(part_name, cur->part.name) == 0)
			break;
		cur = cur->next;
	}
	if (!cur) {
		printf("Partition error: partition %s is not found\n", part_name);
		return -1;
	}
	write(fd, context + cur->part.offset, cur->part.size);

	return 0;
}

static void list_all_partition(int fd, struct part_list *part_head)
{
	int rlen, i = 0;
	char version[MAX_VERSION_SIZE];
	struct part_list *cur = part_head;

	lseek(fd, 0, SEEK_SET);
	rlen = read(fd, version, sizeof(version));
	if (rlen < 0) {
		printf("Read error: read firmware failed\n");
		return;
	}
	printf("FIRMWARE VERSION: %s\n", version);
	printf("%-15s %-40s %-20s %-20s %-25s\n",
			"Index", "Part Name", "Offset","Size(Hex)", "Load Address(Hex)");
	while (cur) {
		i++;
		printf("%-15d %-40s %-20X %-20X %-25lX\n",
			i, cur->part.name, cur->part.offset, cur->part.size, cur->part.lma);
		cur = cur->next;
	}
}

int main(int argc, char *argv[])
{
	int ret, opt, file_fd, firm_fd;
	int *longindex = NULL;
	char *file_name, *firm_name, *part_name = NULL;
	uint32_t file_size, firm_size, size, rlen, offset, sel = 0;
	uint32_t tab_off = PARTITION_TABLE_BASE;
	uint64_t lma = 0;
	uint8_t *context, *temp;
	struct stat file_stat, firm_stat;
	struct part_list *part_head = NULL;

	while ((opt = getopt_long(argc, argv, optstring, longopts, longindex)) != -1) {
		switch (opt) {
			case 'h':
				SELECT(sel, OPTION_HELP);
				printf("OPTIONS:\n"
					"-a, --add Add partition from TARGET-FIRMWARE\n"
					"-e, --extract Extract partition from TARGET-FIRMWARE\n"
					"-f, --file Specific output file of extracted partition or input file of added partition\n"
					"-h, --help Show the usage of the pack tool\n"
					"-l, --loader Load address of the partition\n"
					"-o, --offset Offset of the partition\n"
					"-p, --partition Partition name\n"
					"-s, --size Size of the TARGET-FIRMWARE\n"
					"-t, --table Partition table base address\n");
				break;
			case 'a':
				SELECT(sel, OPTION_ADD);
				break;
			case 'e':
				SELECT(sel, OPTION_EXTRACT);
				break;
			case 't':
				SELECT(sel, OPTION_TABLEINFO);
				tab_off = strtoul(optarg, NULL, 16);
				break;
			case 'p':
				SELECT(sel, OPTION_PARTNAME);
				part_name = optarg;
				break;
			case 'o':
				SELECT(sel, OPTION_OFFSET);
				offset = strtoul(optarg, NULL, 16);
				break;
			case 'f':
				SELECT(sel, OPTION_FILEPATH);
				file_name = optarg;
				break;
			case 'l':
				SELECT(sel, OPTION_LOADADDR);
				lma = strtoul(optarg, NULL, 16);
				break;
			case 's':
				SELECT(sel, OPTION_FIRMWARESIZE);
				size = strtoul(optarg, NULL, 16);
				break;
			case '?':
			default:
				printf("Param error: input pack '-h' to see the detailed usage\n");
		}
	}
	if (sel & MASK(OPTION_HELP))
		return 0;
	firm_name = argv[optind];
	if (!firm_name) {
		printf("Param error: the firmware name must specific\n");
		return -1;
	}
	firm_fd = open(firm_name,  O_CREAT | O_RDWR, 0644);
	if (firm_fd < 0) {
		printf("Open error: open file %s failed\n", firm_name);
		return -1;
	}
	ret = stat(firm_name, &firm_stat);
	if (ret < 0) {
		printf("Stat error: get file %s stat failed\n", firm_name);
		close(firm_fd);
		return -1;
	}
	firm_size = firm_stat.st_size;
	context = load_context(firm_fd, firm_size);
	if (!context)
		goto failed;
	if (sel & MASK(OPTION_TABLEINFO))
		part_head = gen_table(context, tab_off);
	if (!sel || sel == COMMAND_SHOW_PARTITION) {
		list_all_partition(firm_fd, part_head);
		free(context);
		close(firm_fd);
		return 0;
	}
	if (!(sel & MASK(OPTION_ADD)) && !(sel & MASK(OPTION_EXTRACT))) {
		printf("Param error: option '-a' or '-e' must choose one\n");
		goto failed;
	}
	if (sel & MASK(OPTION_ADD)) {
		if (sel & MASK(OPTION_PARTNAME)) {
			if (check_partition_name(part_head, part_name))
				goto failed;
		}
		if ((sel & MASK(OPTION_FILEPATH)) && file_name) {
			file_fd = open(file_name, O_RDONLY, 0);
			if (file_fd < 0) {
				printf("Open error: file %s open failed\n", file_name);
				goto failed;
			}
			ret = stat(file_name, &file_stat);
			if (ret < 0 || !file_stat.st_size) {
				printf("Stat error: get file %s stat failed\n", file_name);
				goto failed;
			}
			file_size = file_stat.st_size;
			temp = (char *)malloc(file_size);
			if (!temp) {
				printf("Memory error: file %s allocate memory failed\n", file_name);
				goto failed;
			}
			rlen = read(file_fd, temp, file_size);
			if (rlen < 0) {
				printf("Read error: read file %s failed\n", file_name);
				free(temp);
				goto failed;
			}
		} else {
			temp = (char *)malloc(MAX_BUFFER_SIZE);
			if (!temp) {
				printf("Memory error: input allocate failed\n");
				goto failed;
			}
			file_fd = STDIN_FILENO;
			file_size = read(file_fd, temp, MAX_BUFFER_SIZE);
			if (file_size >= MAX_BUFFER_SIZE) {
				printf("Input error: the size of input from stdin should less than 256\n");
				free(temp);
				goto failed;
			}
		}
		if (sel & MASK(OPTION_OFFSET)) {
			if (check_borders(part_head, offset, file_size, tab_off)) {
				printf("Layer error: this file is over layer\n");
				free(temp);
				goto failed;
			}
			part_head = update_table(part_head, part_name, offset, file_size, lma);
		} else
			part_head = auto_update_table(part_head, part_name, tab_off, &offset, file_size, lma);
		rlen = update_context(context, part_head, tab_off, temp, offset, file_size);
		firm_size = firm_size > rlen ? firm_size : rlen;
		free(temp);
		if (sel & MASK(OPTION_FIRMWARESIZE)) {
			if (size < firm_size) {
				printf("Size error: input size should larger than currnt firmware\n");
				goto failed;
			}
			if (ftruncate(firm_fd, size) == -1) {
				perror("Size error: ftruncate failed\n");
				goto failed;
			}
			firm_size = size;
		}
		flush_context(firm_fd, context, firm_size);
	} else if (sel & MASK(OPTION_EXTRACT)) {
		if (sel & MASK(OPTION_PARTNAME)) {
			if (sel & MASK(OPTION_FILEPATH)) {
				file_fd = open(file_name, O_CREAT | O_RDWR, 0644);
				if (file_fd < 0) {
					printf("Open error: open %s failed\n", file_name);
					goto failed;
				}
			} else
				file_fd = STDOUT_FILENO;
			ret = extract_context(context, part_head, part_name, file_fd);
			if (ret)
				goto failed;
		}
	}
	free(context);
	close(firm_fd);
	return 0;

failed:
	free(context);
	close(firm_fd);
	return -1;
}