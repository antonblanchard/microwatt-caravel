#include <stdint.h>

#include "microwatt_util.h"

#define SIMPLEBUS_CONFIG 0xc8000000
#define EXT_BUS_OFFSET 0x40000000

int main(void)
{
	uint64_t *p = (uint64_t *)EXT_BUS_OFFSET;
	uint64_t *q = (uint64_t *)(EXT_BUS_OFFSET+128);

	microwatt_alive();

	// Enable simplebus
	*(uint32_t *)SIMPLEBUS_CONFIG = 0x8 | 0x1;
	__asm__ __volatile__("");

	*p = 0xACEACEACEACEACEA;
	__asm__ __volatile__("");

	if (*q == 0x0102030405060708) {
		writel(0x00080000, GPIO_REG_DIR);
		writel(0x00080000, GPIO_REG_OUT);
	}

	// We only have 1 spare pin to communicate status, so
	// failure is represented by a timeout.
	while (1)
		/* Do Nothing */ ;
}
