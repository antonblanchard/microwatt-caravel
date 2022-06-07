#include <stdint.h>

#include "microwatt_util.h"
#include "console.h"

static inline uint64_t ppc_mulld(uint64_t a, uint64_t b)
{
	uint64_t res;
	__asm__ ("mulld %0,%1,%2" : "=r"(res) : "r"(a), "r"(b));

	return res;
}

static inline uint64_t ppc_mulhdu(uint64_t a, uint64_t b)
{
	uint64_t res;
	__asm__ ("mulhdu %0,%1,%2" : "=r"(res) : "r"(a), "r"(b));

	return res;
}

static inline int64_t ppc_mulhd(int64_t a, int64_t b)
{
	int64_t res;
	__asm__ ("mulhd %0,%1,%2" : "=r"(res) : "r"(a), "r"(b));

	return res;
}

static inline uint32_t ppc_mullw(uint32_t a, uint32_t b)
{
	uint32_t res;
	__asm__ ("mullw %0,%1,%2" : "=r"(res) : "r"(a), "r"(b));

	return res;
}

static inline uint32_t ppc_mulhwu(uint32_t a, uint32_t b)
{
	uint32_t res;
	__asm__ ("mulhwu %0,%1,%2" : "=r"(res) : "r"(a), "r"(b));

	return res;
}

static inline int32_t ppc_mulhw(int32_t a, int32_t b)
{
	int32_t res;
	__asm__ ("mulhw %0,%1,%2" : "=r"(res) : "r"(a), "r"(b));

	return res;
}

static inline uint64_t ppc_maddld(uint64_t a, uint64_t b, uint64_t c)
{
	uint64_t res;
	__asm__ ("maddld %0,%1,%2,%3" : "=r"(res) : "r"(a), "r"(b), "r"(c));

	return res;
}

static inline uint64_t ppc_maddhdu(uint64_t a, uint64_t b, uint64_t c)
{
	uint64_t res;
	__asm__ ("maddhdu %0,%1,%2,%3" : "=r"(res) : "r"(a), "r"(b), "r"(c));

	return res;
}

static inline uint64_t ppc_maddhd(int64_t a, int64_t b, int64_t c)
{
	int64_t res;
	__asm__ ("maddhd %0,%1,%2,%3" : "=r"(res) : "r"(a), "r"(b), "r"(c));

	return res;
}

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

static void expect(char *insn, uint64_t got, uint64_t exp)
{
	if (exp != got) {
		print_hex(exp);
		putchar(' ');
		print_hex(got);

		microwatt_failure();

		while (1)
			/* Do Nothing */ ;
	}
}

#define SIGNED_A	-1245234234L
#define SIGNED_B	5434564742966924118UL
#define SIGNED_C	-5551512323435643331L

#define UNSIGNED_A	89471432132552525UL
#define UNSIGNED_B	5434564742966924118UL
#define UNSIGNED_C	17184923449516151310UL

#define SIGNED_A_32	-1245234234L
#define SIGNED_B_32	543456474U

#define UNSIGNED_A_32	894714321U
#define UNSIGNED_B_32	543456474U

int main(void)
{
	console_init();
	microwatt_alive();

	expect("mulld", ppc_mulld(UNSIGNED_A, UNSIGNED_B), 0x2806d04a5b762ade);
	expect("muldhu", ppc_mulhdu(UNSIGNED_A, UNSIGNED_B), 0x5da5660c80b36e);
	expect("mulhd", ppc_mulhd(SIGNED_A, SIGNED_B), 0xffffffffea223733);

	expect("maddld", ppc_maddld(UNSIGNED_A, UNSIGNED_B, UNSIGNED_C), 0x1683ed1e4026fcec);
	expect("maddhdu", ppc_maddhdu(UNSIGNED_A, UNSIGNED_B, UNSIGNED_C), 0x5da5660c80b36f);
	expect("maddhd", ppc_maddhd(SIGNED_A, SIGNED_B, SIGNED_C), 0xffffffffea223732);

	// Test 32 bit multiplies
	expect("mullw", ppc_mullw(UNSIGNED_A_32, UNSIGNED_B_32), 0xf4547fa);
	expect("mulhwu", ppc_mulhwu(UNSIGNED_A_32, UNSIGNED_B_32), 0x6bf7726);
	expect("mulhw", ppc_mulhw(SIGNED_A_32, SIGNED_B_32), 0xfffffffff69bc519);

	microwatt_success();

	while (1)
		/* Do Nothing */ ;
}
