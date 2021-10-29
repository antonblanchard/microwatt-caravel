#include "microwatt_util.h"
#include "console.h"
#include "hash.h"

extern char *__bss_end[];
#define START (unsigned long)__bss_end
#define END 0x1000

static void print_hex(unsigned long val)
{
	int i, x;

	for (i = 60; i >= 0; i -= 4) {
		x = (val >> i) & 0xf;
		if (x >= 10)
			putchar(x + 'a' - 10);
		else
			putchar(x + '0');
	}
}

int main(void)
{
	console_init();
	microwatt_alive();

	for (unsigned long i = START; i < END; i += 8) {
		unsigned long val = hash_64(i, 64);
		*(unsigned long *)i = val;
	}

	for (unsigned long i = START; i < END; i+=8) {
		unsigned long exp;
		unsigned long got;

		exp = hash_64(i, 64);
		got = *(unsigned long *)i;

		if (exp != got) {
			print_hex(exp);
			print_hex(got);

			microwatt_failure();
			goto out;
		}
	}

	microwatt_success();

out:
	while (1)
		/* Do Nothing */ ;
}
