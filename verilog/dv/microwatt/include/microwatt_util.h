#ifndef __MICROWATT_UTIL_H
#define __MICROWATT_UTIL_H

#include "io.h"

#define GPIO_REG_OUT		0xc0007000
#define GPIO_REG_DIR		0xc0007008
/* low 16 bits output, high 3 bits input */
#define GPIO_REG_DIR_CONF	0x0000ffff

#define GPIO_MICROWATT_START	0x00000ffe
#define GPIO_MICROWATT_SUCCESS	0x000000d5
#define GPIO_MICROWATT_FAILURE 	0x00007345

#ifdef __powerpc64__
static inline void microwatt_alive(void)
{
	writel(GPIO_REG_DIR_CONF, GPIO_REG_DIR);
	writel(GPIO_MICROWATT_START, GPIO_REG_OUT);
}

static inline void microwatt_success(void)
{
	writel(GPIO_REG_DIR_CONF, GPIO_REG_DIR);
	writel(GPIO_MICROWATT_SUCCESS, GPIO_REG_OUT);
}

static inline void microwatt_failure(void)
{
	writel(GPIO_REG_DIR_CONF, GPIO_REG_DIR);
	writel(GPIO_MICROWATT_FAILURE, GPIO_REG_OUT);
}
#endif

#endif
