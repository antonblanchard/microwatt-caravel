#include <stdint.h>
#include <stdbool.h>

#include "microwatt_util.h"
#include "microwatt_soc.h"

#define SIMPLEBUS_CONFIG 0xc8000000
#define EXT_BUS_OFFSET 0x40000000

int main(void)
{
	// With simplebus hooked up to our GPIO pins, we only have 10
	// bits we can use as outputs
	writel(0x3FF, GPIO_REG_DIR);
	writel(0x3f8, GPIO_REG_OUT);

	// Enable simplebus
	*(volatile uint32_t *)SIMPLEBUS_CONFIG = 0x8 | 0x1;

	/* Move external bus to 0 */
	writeq(SYS_REG_CTRL_DRAM_AT_0, SYSCON_BASE + SYS_REG_CTRL);

	/* Jump into micropython */
	void (*fn)() = 0x0;
	fn();

	/* Not reached */

	while (1)
		/* Do Nothing */ ;
}
