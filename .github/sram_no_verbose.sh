#!/bin/bash

if [ -z "$PDK_ROOT" ]; then
	echo "Must set PDK_ROOT"
	exit 1
fi

SRAM_FILES=$(find $PDK_ROOT -name sky130_sram_*.v)

for FILE in $SRAM_FILES; do
	sed -i 's/VERBOSE = 1/VERBOSE = 0/g' $FILE
done
