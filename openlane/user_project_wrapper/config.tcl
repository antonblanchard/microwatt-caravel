# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0

# Base Configurations. Don't Touch
# section begin

set ::env(PDK) "sky130A"
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"

# YOU ARE NOT ALLOWED TO CHANGE ANY VARIABLES DEFINED IN THE FIXED WRAPPER CFGS
source $::env(CARAVEL_ROOT)/openlane/user_project_wrapper/fixed_wrapper_cfgs.tcl

# YOU CAN CHANGE ANY VARIABLES DEFINED IN THE DEFAULT WRAPPER CFGS BY OVERRIDING THEM IN THIS CONFIG.TCL
source $::env(CARAVEL_ROOT)/openlane/user_project_wrapper/default_wrapper_cfgs.tcl

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) user_project_wrapper
#section end

set ::env(FP_PDN_CORE_RING_VOFFSET) 12.45
set ::env(FP_PDN_CORE_RING_HOFFSET) 12.45

# User Configurations

## Source Verilog Files
set ::env(VERILOG_FILES) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$script_dir/../../verilog/rtl/microwatt.v \
	$script_dir/../../verilog/rtl/user_project_wrapper.v"

## Clock configurations
set ::env(CLOCK_PORT) "user_clock2"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)
set ::env(BASE_SDC_FILE) $script_dir/base.sdc
 
# Speed up?
set ::env(CLOCK_PERIOD) "20"

## Internal Macros
### Macro PDN Connections
set ::env(FP_PDN_MACRO_HOOKS) "\
	microwatt_0.soc0.bram.bram0.ram_0.memory_0				vccd1 vssd1, \
	microwatt_0.soc0.processor.dcache_0.rams:1.way.cache_ram_0		vccd1 vssd1, \
	microwatt_0.soc0.processor.icache_0.rams:1.way.cache_ram_0		vccd1 vssd1, \
	microwatt_0.soc0.processor.execute1_0.multiply_0.multiplier		vccd1 vssd1, \
	microwatt_0.soc0.processor.with_fpu.fpu_0.fpu_multiply_0.multiplier	vccd1 vssd1, \
	microwatt_0.soc0.processor.register_file_0.register_file_0		vccd1 vssd1"

### Macro Placement
set ::env(MACRO_PLACEMENT_CFG) $script_dir/macro.cfg

### Black-box verilog and views
set ::env(VERILOG_FILES_BLACKBOX) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$script_dir/../../verilog/rtl/wrapper/RAM512.v \
	$script_dir/../../verilog/rtl/wrapper/RAM32_1RW1R.v \
	$script_dir/../../verilog/rtl/wrapper/Microwatt_FP_DFFRFile.v \
	$script_dir/../../verilog/rtl/wrapper/multiply_add_64x64.v"

set ::env(EXTRA_LEFS) "\
	$script_dir/../../lef/RAM512.lef \
	$script_dir/../../lef/RAM32_1RW1R.lef \
	$script_dir/../../lef/Microwatt_FP_DFFRFile.lef \
	$script_dir/../../lef/multiply_add_64x64.lef"

set ::env(EXTRA_GDS_FILES) "\
	$script_dir/../../gds/RAM512.gds \
	$script_dir/../../gds/RAM32_1RW1R.gds \
	$script_dir/../../gds/Microwatt_FP_DFFRFile.gds \
	$script_dir/../../gds/multiply_add_64x64.gds"

set ::env(EXTRA_LIBS) "\
	$script_dir/RAM512.lib \
	$script_dir/RAM32_1RW1R.lib \
	$script_dir/Microwatt_FP_DFFRFile.lib \
	$script_dir/multiply_add_64x64.lib"

# disable pdn check nodes becuase it hangs with multiple power domains.
# any issue with pdn connections will be flagged with LVS so it is not a critical check.
##set ::env(FP_PDN_CHECK_NODES) 0

# Synthesis tuning
set ::env(SYNTH_MAX_FANOUT) {10}
set ::env(SYNTH_STRATEGY) {DELAY 4}

# Floor plan tuning
set ::env(FP_TAP_HORIZONTAL_HALO) 40
set ::env(FP_PDN_HORIZONTAL_HALO) 40
set ::env(FP_TAP_VERTICAL_HALO) 10
set ::env(FP_PDN_VERTICAL_HALO) 10

# Placement tuning
set ::env(PL_TARGET_DENSITY) 0.25
set ::env(PL_RESIZER_HOLD_SLACK_MARGIN) "0.3"

set ::env(CELL_PAD) 6

# Global routing tuning
set ::env(GLB_RT_ADJUSTMENT) 0.2

# CTS tuning
set ::env(CTS_CLK_BUFFER_LIST) {sky130_fd_sc_hd__clkbuf_8 sky130_fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_2};
set ::env(CTS_DISABLE_POST_PROCESSING) 1
set ::env(CTS_SINK_CLUSTERING_MAX_DIAMETER) 200
set ::env(CTS_DISTANCE_BETWEEN_BUFFERS) 1000

# Speed up tape out a bit
set ::env(RUN_KLAYOUT) 0

if {[catch {exec nproc} result] == 0} {
	set ::env(ROUTING_CORES) $result
} else {
	set ::env(ROUTING_CORES) 24
}

set ::env(DIODE_INSERTION_STRATEGY) 0
