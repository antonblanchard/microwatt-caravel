#!/bin/bash -e

# Where to do tape out - WARNING: needs ~20GB of disk
export MPW=/scratch/mpw8

# Build macros in parallel - WARNING: needs lots of RAM
PARALLEL=1

export PDK=sky130A

export ROUTING_CORES=$(nproc)

export OPENLANE_ROOT=$MPW/OpenLane
export PDK_ROOT=$OPENLANE_ROOT/pdks
export CARAVEL_USER_PROJECT_ROOT=$MPW/caravel_user_project
export CARAVEL_ROOT=$CARAVEL_USER_PROJECT_ROOT/caravel
export MCW_ROOT=$CARAVEL_USER_PROJECT_ROOT/mgmt_core_wrapper

mkdir -p $MPW
cd $MPW

git clone --depth 1 https://github.com/antonblanchard/microwatt-caravel -b sky130-mpw8-tapeout-1 caravel_user_project

git clone --depth 1 https://github.com/antonblanchard/DFFRAM -b microwatt-20221228

git clone --depth 1 https://github.com/antonblanchard/microwatt -b caravel-mpw7-20221125

cd caravel_user_project

# Install OpenLane, pdks, caravel and mgmt_core_wrapper
make setup

# Shouldn't have any compresed/split files yet, but just in case
make uncompress

# Set OPENLANE_IMAGE_NAME so we use the same toolchain to build DFFRAM (Assume we are on a tag)
#cd $MPW/OpenLane
#OPENLANE_COMMIT=$(git describe --tags)
#export OPENLANE_IMAGE_NAME=efabless/openlane:$OPENLANE_COMMIT

# Convert Microwatt to Verilog
cd $MPW/microwatt
make DOCKER=1 FPGA_TARGET=caravel microwatt_asic.v && ./caravel/process-microwatt-verilog.sh
cd $MPW/caravel_user_project

# copy in Microwatt Verilog
cp $MPW/microwatt/microwatt_asic_processed.v verilog/rtl/microwatt.v

cat > $MPW/DFFRAM/ram512_pin_order.cfg << EOF
#S
A0.*
Di0.*
CLK
Do0.*
WE0.*
EN0.*
EOF

cat > $MPW/DFFRAM/ram32_1rw1r_pin_order.cfg << EOF
#N
CLK
EN0.*
EN1.*
WE0.*
A0.*
A1.*
Di0.*
Do1.*
#S
Do0.*
EOF

if [ $PARALLEL -eq 1 ]; then
	cd $MPW/DFFRAM
	# Build cache and main RAM DFFRAMs
	./dffram.py --pdk-root $PDK_ROOT --size 32x64 --variant 1RW1R --min-height 180 --pin_order=ram32_1rw1r_pin_order.cfg > $MPW/1.out 2>&1 &
	./dffram.py --pdk-root $PDK_ROOT --size 512x64 --vertical-halo 100 --horizontal-halo 20 --pin_order=ram512_pin_order.cfg > $MPW/2.out 2>&1 &
	cd $MPW/caravel_user_project

	make multiply_add_64x64 > $MPW/3.out 2>&1 &
	make Microwatt_FP_DFFRFile > $MPW/4.out 2>&1 &

	wait

	cat $MPW/1.out $MPW/2.out $MPW/3.out $MPW/4.out
else
	cd $MPW/DFFRAM
	# Build cache and main RAM DFFRAMs
	./dffram.py --pdk-root $PDK_ROOT --size 32x64 --variant 1RW1R --min-height 180 --pin_order=ram32_1rw1r_pin_order.cfg
	./dffram.py --pdk-root $PDK_ROOT --size 512x64 --vertical-halo 100 --horizontal-halo 20 --pin_order=ram512_pin_order.cfg
	cd $MPW/caravel_user_project

	make multiply_add_64x64
	make Microwatt_FP_DFFRFile
fi

# copy in RAMS
for RAM in 512x64_DEFAULT 32x64_1RW1R
do
	cd $MPW/DFFRAM/build/$RAM/products
	tar cf - . | (cd $CARAVEL_USER_PROJECT_ROOT && tar xvf -)
	cd -
done

make user_project_wrapper

echo SUCCESS
