/*
 * pack all thing to a image
 */
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>

#include <global.h>
#include <md5.h>
#include <common.h>
#include <log.h>

#define FLASH_SIZE		(64 * 1024)
#define PROGRAM_LIMIT		(FLASH_SIZE - 128)

#define MD5_START		(PROGRAM_LIMIT)
#define MD5_SIZE		(16)
#define MD5_END			(MD5_START + MD5_SIZE)

#define FWINFO_START		(MD5_END)
#define FWINFO_SIZE		(FWINFO_END - FWINFO_START)
#define FWINFO_END		(FLASH_SIZE)

#define LOADER_START		0
#define LOADER_SIZE		(28 * 1024)
#define LOADER_END		(LOADER_START + LOADER_SIZE)

#define EFIT_START		LOADER_END
#define EFIT_SIZE		(4 * 1024)
#define EFIT_END		(EFIT_START + EFIT_SIZE)
#define EFIE_SIZE		(128)

void usage_v1(void)
{
	printf("pack loader application application-offset upgrader upgrader-offset flash-image-file\n");
}

static int is_invalid(struct comp *loader, struct comp *app,
		      struct comp *upgrader)
{
	// check offset
	if (app->efie.offset < EFIT_END) {
		error("application start offset should over efit end\n");
		return -1;
	}

	if (upgrader->efie.offset < EFIT_END) {
		error("upgrader start offset should over efit end\n");
		return -1;
	}

	if (loader->efie.length >= EFIT_START) {
		error("loader size too big\n");
		return -1;
	}

	unsigned long region0_start = app->efie.offset;
	unsigned long region0_end = app->efie.offset + app->efie.length;
	unsigned long region1_start = upgrader->efie.offset;
	unsigned long region1_end = upgrader->efie.offset +
					upgrader->efie.length;

	if (!(region0_end <= region1_start || region0_start >= region1_end)) {
		error("application and upgrader overlay\n");
		return -1;
	}

	if (region0_end > PROGRAM_LIMIT) {
		error("application out of valid program region\n");
		return -1;
	}
	if (region1_end > PROGRAM_LIMIT) {
		error("upgrader out of valid program region\n");
		error("end of upgrader 0x%08lx\n", region1_end);
		return -1;
	}

	return 0;
}

int pack_v1(int argc, char *argv[])
{
	int err = -1;

	if (argc != 7 && argc != 8) {
		return 1;
	}
	assert(sizeof(struct efie) == 128);
	struct comp app, loader, upgrader;
	unsigned char *image;
	image = malloc(FLASH_SIZE);
	if (image == NULL) {
		error("cannot alloc memory for image\n");
		return 1;
	}
	memset(image, 0x00, FLASH_SIZE);
	if (load_file(&loader, argv[1])) {
		err = -1;
		goto free_image;
	}
	if (load_file(&app, argv[2])) {
		err = -1;
		goto unload_loader;
	}
	if (load_file(&upgrader, argv[4])) {
		err = -1;
		goto unload_app;
	}

	loader.efie.offset = 0;
	app.efie.offset = strtol(argv[3], NULL, 0);
	upgrader.efie.offset = strtol(argv[5], NULL, 0);

	print_efie(&loader.efie);
	print_efie(&app.efie);
	print_efie(&upgrader.efie);

	if (is_invalid(&loader, &app, &upgrader)) {
		err = -1;
		goto unload_upgrader;
	}

	memcpy(image + loader.efie.offset, loader.buf, loader.size);
	memcpy(image + app.efie.offset, app.buf, app.size);
	memcpy(image + upgrader.efie.offset, upgrader.buf, upgrader.size);

	memcpy(image + EFIT_START, &app.efie, EFIE_SIZE);
	memcpy(image + EFIT_START + EFIE_SIZE, &upgrader.efie, EFIE_SIZE);

	/* calculate md5sum, from 0 to 64K - 16 */
	MD5_CTX md_ctx;
	MD5Init(&md_ctx);
	unsigned long md_size = PROGRAM_LIMIT;
	void *dgst = image + md_size;
	MD5Update(&md_ctx, image, md_size);
	MD5Final(dgst, &md_ctx);

	char *output_file;
	/* append firmware information */
	if (argc == 8) {
		struct fwinfo *fwinfo;

		fwinfo = (void *)(image + FWINFO_START);
		init_fwinfo(fwinfo);
		fwinfo->type = strtol(argv[6], NULL, 0);
		output_file = argv[7];
	} else {
		output_file = argv[6];
	}

	store_file(image, FLASH_SIZE, output_file);

	err = 0;
unload_upgrader:
	unload_file(&upgrader);
unload_app:
	unload_file(&app);
unload_loader:
	unload_file(&loader);
free_image:
	free(image);
	return err;
}

