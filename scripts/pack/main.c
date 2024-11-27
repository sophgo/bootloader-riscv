#include <stdio.h>

extern int pack_v1(int argc, char *argv[]);
extern int pack_v2(int argc, char *argv[]);
extern void usage_v1(void);
extern void usage_v2(void);

int main(int argc, char *argv[])
{
	int err;
	int (*pack)(int argc, char *argv[]);

	if (argc == 7 || argc == 8)
		pack = pack_v1;
	else
		pack = pack_v2;

	err = pack(argc, argv);
	if (err) {
		printf("\nusage:\n");
		usage_v1();
		usage_v2();
	}
	return err;
}
