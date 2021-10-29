/* Copyright 2013-2014 IBM Corp.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * 	http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define GPIO_BASE	0xc0007000
#define GPIO_OUT	0x0
#define GPIO_DIR	0x8

#define GPIO_MICROWATT_SUCCESS 0x00d5

/* Load an immediate 64-bit value into a register */
#define LOAD_IMM64(r, e)			\
	lis	r,(e)@highest;			\
	ori	r,r,(e)@higher;			\
	rldicr	r,r, 32, 31;			\
	oris	r,r, (e)@h;			\
	ori	r,r, (e)@l;

	.section ".head","ax"
	.global _start
_start:
	LOAD_IMM64(%r3, GPIO_BASE)

	addi	%r4,%r3,GPIO_DIR
	li	%r5,-1
	rldicl	%r5,%r5,0,48	// 16 bits output, 16 bits input
	stwcix	%r5,0,%r4

	addi	%r4,%r3,GPIO_OUT
	LOAD_IMM64(%r5, GPIO_MICROWATT_SUCCESS)
	stwcix	%r5,0,%r4

1:	b 1b
