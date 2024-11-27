#ifndef __LOG_H__
#define __LOG_H__

#include <stdio.h>

#if 0
#define debug(...)	printf("[DEBUG]: " __VA_ARGS__)
#else
#define debug(...)	do {} while (0)
#endif

#define error(...)	fprintf(stderr, "[ERROR]: " __VA_ARGS__)
#define warn(...)	fprintf(stderr, "[WARN]: " __VA_ARGS__)



#endif
