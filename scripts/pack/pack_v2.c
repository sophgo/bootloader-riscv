/*
 * pack all thing to an image
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
#include <ezxml/ezxml.h>
#include <log.h>
#include <common.h>

struct image {
	void *img, *map;
	unsigned long size;
};

static struct image *img_alloc(unsigned long size)
{
	struct image *img;

	img = malloc(sizeof(*img) + size * 2);
	if (img == NULL)
		return NULL;

	img->img = ((char *)img) + sizeof(*img);
	img->map = img->img + size;
	img->size = size;
	memset(img->img, 0x00, size * 2);

	return img;
}

static int img_final(struct image *img, char *file)
{
	/* calculate md5sum, from 0 to 64K - 128 */
	unsigned long md_size = img->size - 128;
	void *dgst = img->img + md_size;
	MD5_CTX md_ctx;

	MD5Init(&md_ctx);
	MD5Update(&md_ctx, img->img, md_size);
	MD5Final(dgst, &md_ctx);

	return store_file(img->img, img->size, file);
}

static void img_free(struct image *img)
{
	free(img);
}

static int img_fill(struct image *img, unsigned long offset,
		    void *src, unsigned long len)
{
	/* check overlap */
	unsigned char *dst = ((unsigned char *)img->img) + offset;
	unsigned char *map = ((unsigned char *)img->map) + offset;

	unsigned long i;

	for (i = 0; i < len; ++i)
		if (map[i]) /* overlap */
			return -1;

	for (i = 0; i < len; ++i) {
		dst[i] = ((unsigned char *)src)[i];
		map[i] = 1;
	}

	return 0;
}

void usage_v2(void)
{
	printf("pack xml-configuration-file output-firmware-file\n");
}

int pack_v2(int argc, char *argv[])
{
	int err;
	ezxml_t p;
	char * __attribute__((unused)) firmware_name = "unknown_firmware";
	char * __attribute__((unused)) mcu_family_name = "STM32L0";
	unsigned long firmware_size = 64 * 1024;
	struct image *img;

	if (argc != 3) {
		error("invalid argument\n");
		return 1;
	}

	char *file = argv[1];
	debug("parsing file %s\n", file);

	ezxml_t firmware = ezxml_parse_file(file);
	if (strcmp(firmware->name, "firmware")) {
		error("not a valid layout file\n");
		err = 1;
		goto err_xml;
	}
	/* firmware name */
	p = ezxml_child(firmware, "name");
	if (p == NULL )
		warn("warn: cannot find firmware name\n");

	firmware_name = p->txt;


	p = ezxml_child(firmware, "family");
	if (p)
		mcu_family_name = p->txt;

	p = ezxml_child(firmware, "size");
	if (p == NULL)
		warn("warn: cannot find firmware size, use default %lu\n",
		     firmware_size);

	firmware_size = strtol(p->txt, NULL, 0);

	debug("firmware name %s, size %lu\n",
	      firmware_name, firmware_size);

	debug("parsing executable file table\n");

	ezxml_t efit;
	efit = ezxml_child(firmware, "efit");
	if (efit == NULL) {
		error("no efit node\n");
		err = 1;
		goto err_xml;
	}
	unsigned long efit_offset;
	p = ezxml_child(efit, "offset");
	if (p == NULL) {
		error("no efit offset\n");
		err = 1;
		goto err_xml;
	}
	efit_offset = strtol(p->txt, NULL, 0);
	p = ezxml_child(efit, "size");
	if (p == NULL) {
		error("no efit size\n");
		err = 1;
		goto err_xml;
	}
	debug("efit offset 0x%08lx", efit_offset);

	debug("parsing components\n");


	img = img_alloc(firmware_size);
	if (img == NULL) {
		error("memory overflow\n");
		err = 1;
		goto err_xml;
	}

	/* append firmware information */
	int firmware_type = get_firmware_type(firmware_name);
	if (firmware_type < 0) {
		error("unknown firmware type %s\n", firmware_name);
		err = 1;
		goto err_xml;
	}

	int mcu_family = get_mcu_family(mcu_family_name);
	if (mcu_family < 0) {
		error("unknown mcu family %s\n", mcu_family_name);
		err = 1;
		goto err_xml;
	}

	if (mcu_family == GD32E50)
		memset(img->img, 0xff, firmware_size);

	struct fwinfo fwinfo;
	init_fwinfo(&fwinfo);
	fwinfo.type = firmware_type;
	fwinfo.mcu_family = mcu_family;
	if (img_fill(img, img->size - 128 + 16, &fwinfo, sizeof(fwinfo))){
		error("firmware information out of range\n");
		err = 1;
		goto err_xml;
	}

	unsigned int component_count;
	for (p = ezxml_child(firmware, "component"), component_count = 0;
	     p;
	     p = p->next, ++component_count) {
		ezxml_t q;
		char *name;
		unsigned int type;
		char *file;
		unsigned long offset;
		q = ezxml_child(p, "name");
		if (q == NULL)
			warn("no name\n");
		name = q->txt;
		q = ezxml_child(p, "type");
		if (q == NULL)
			warn("no type\n");
		type = strtol(q->txt, NULL, 0);
		q = ezxml_child(p, "file");
		if (q == NULL) {
			error("no binary file\n");
			err = 1;
			goto err_img_mem;
		}
		file = q->txt;
		q = ezxml_child(p, "offset");
		if (q == NULL) {
			error("no offset\n");
			err = 1;
			goto err_img_mem;
		}
		offset = strtol(q->txt, NULL, 0);
		debug("%dth component %s, type %u, file %s, offset %lx\n",
		      component_count, name, type, file, offset);
		struct comp comp;
		err = load_file(&comp, file);
		if (err) {
			error("load component failed\n");
			goto err_img_mem;
		}
		comp.efie.offset = offset;
		comp.efie.type = type;
		strncpy((char *)comp.efie.padding, name,
			sizeof(comp.efie.padding) - 1);
		print_efie(&comp.efie);
		if (img_fill(img, offset, comp.buf, comp.size)) {
			error("component overlap\n");
			unload_file(&comp);
			goto err_img_mem;
		}
		if (img_fill(img,
			     efit_offset + sizeof(comp.efie) * component_count,
			     &comp.efie, sizeof(comp.efie))) {
			error("efit overlap\n");
			unload_file(&comp);
			goto err_img_mem;
		}
		unload_file(&comp);
	}
	err = img_final(img, argv[2]);
	if (err) {
		error("store image file error\n");
		err = 1;
	}

err_img_mem:
	img_free(img);
err_xml:
	free(firmware);
	return err;
}

