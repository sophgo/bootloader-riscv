#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#define ARRAY_SIZE(a)	(sizeof(a) / sizeof((a)[0]))

static void bin2hex(uint8_t c, char *s)
{
	const char *l = "0123456789abcdef";

	s[0] = l[c >> 4];
	s[1] = l[c & 0xf];
}

static void usage(void)
{
	printf("mb2h IMAGE HEX\n");
	printf("    HEX may be a pattern, eg. rv-sbi-%%d.hex\n");
	printf("    Output files are rv-sbi-0.hex, rv-sbi-1.hex ...\n");
}

int main(int argc, char *argv[])
{
	FILE *fp;
	FILE *ofp[8];
	unsigned char data[8] = {0};
	int len, read_len;
	int err;
	int i, j;

	char output_file[1024];
	char tmp[1024];

	if (argc == 2)
		strcpy(output_file, "ddr%d.hex");
	else if (argc == 3) {
		if (strstr(argv[2], "%d"))
			strcpy(output_file, argv[2]);
		else
			sprintf(output_file, "%s.%%d", argv[2]);

	} else {
		fprintf(stderr, "error arguments\n");
		usage();
		return -1;
	}

	fp = fopen(argv[1], "r");
	if (fp == NULL) {
		printf("open %s error\n", argv[1]);
		return -1;
	}

	fseek(fp, 0L, SEEK_END);
	len = ftell(fp);
	fseek(fp, 0L, SEEK_SET);

	for (i = 0; i < ARRAY_SIZE(ofp); ++i) {
		sprintf(tmp, output_file, i);
		ofp[i] = fopen(tmp, "w+");
		if (ofp[i] == NULL) {
			fprintf(stderr, "open %s failed\n", tmp);
			return 1;
		}
	}

	tmp[2] = '\n';
	for(i = 0; i < len; i += 8) {
		memset(data, 0, 8);
		read_len = fread(data, 8, 1, fp);
		if (read_len >= 0 && read_len != 1) {
			if (feof(fp)) {
				printf("input file not 8 byte aligned\n");
				printf("padding zero to 8 byte aligned\n");
			}
		} else if (read_len < 0) {
			printf("read error\n");
		}

		for (j = 0; j < 8; ++j) {
			bin2hex(data[j], tmp);
			fwrite(tmp, 3, 1, ofp[j]);
		}
	}

	fclose(fp);

	for (i = 0; i < ARRAY_SIZE(ofp); ++i)
		fclose(ofp[i]);

	return 0;
}
