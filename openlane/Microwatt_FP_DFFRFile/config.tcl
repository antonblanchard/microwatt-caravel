set script_dir $::env(DESIGN_DIR)

set ::env(DESIGN_NAME) Microwatt_FP_DFFRFile

set ::env(VERILOG_FILES) "\
	$script_dir/../../verilog/rtl/Microwatt_FP_DFFRFile.v"

set ::env(CLOCK_PORT) "CLK"
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)
set ::env(BASE_SDC_FILE) $script_dir/base.sdc

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 700 700"

# Settings for macros
set ::env(DESIGN_IS_CORE) 0
set ::env(FP_PDN_CORE_RING) 0
set ::env(RT_MAX_LAYER) "met4"

# Macro pin out
set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

# Macro input/output delay - must match liberty file
set ::env(IO_PCT) 0.3

# Handle PDN
set ::env(VDD_NETS) [list {VPWR} ]
set ::env(GND_NETS) [list {VGND} ]

# Make PDN match top level
set ::env(FP_PDN_VWIDTH) 3.1
set ::env(FP_PDN_HWIDTH) 3.1
set ::env(FP_PDN_VSPACING) [expr 5*$::env(FP_PDN_VWIDTH)]
set ::env(FP_PDN_HSPACING) [expr 5*$::env(FP_PDN_HWIDTH)]

# PDN Pitch
set ::env(FP_PDN_VPITCH) 180
set ::env(FP_PDN_HPITCH) $::env(FP_PDN_VPITCH)

# PDN Offset
set ::env(FP_PDN_VOFFSET) 5
set ::env(FP_PDN_HOFFSET) $::env(FP_PDN_VOFFSET)

# Synthesis tuning
set ::env(SYNTH_STRATEGY) {DELAY 4}
set ::env(SYNTH_MAX_FANOUT) {10}

# Placement tuning
set ::env(PL_TARGET_DENSITY) 0.68

# CTS tuning
set ::env(CTS_CLK_BUFFER_LIST) {sky130_fd_sc_hd__clkbuf_8 sky130_fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_2};
set ::env(CTS_DISABLE_POST_PROCESSING) 1
set ::env(CTS_DISTANCE_BETWEEN_BUFFERS) 250

# Speed up tape out a bit
set ::env(RUN_KLAYOUT) 0

if {[catch {exec nproc} result] == 0} {
	set ::env(ROUTING_CORES) $result
} else {
	set ::env(ROUTING_CORES) 4
}

set ::env(GPL_CELL_PADDING) 2
set ::env(DPL_CELL_PADDING) 0
set ::env(DIODE_PADDING) 0
