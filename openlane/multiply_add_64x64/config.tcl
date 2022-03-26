set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) multiply_add_64x64

set ::env(VERILOG_FILES) "\
	$script_dir/src/multiply_add_64x64.v"

set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 550 550"

# Settings for macros
set ::env(DESIGN_IS_CORE) 0
set ::env(FP_PDN_CORE_RING) 0
set ::env(RT_MAX_LAYER) "met4"

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

# Tuning
set ::env(PL_TARGET_DENSITY) 0.36

# Because the macro uses standard cells
set ::env(SYNTH_READ_BLACKBOX_LIB) 1

set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

if {[catch {exec nproc} result] == 0} {
	set ::env(ROUTING_CORES) $result
} else {
	set ::env(ROUTING_CORES) 4
}

#set ::env(IO_PCT) 0.5

set ::env(PL_RESIZER_HOLD_SLACK_MARGIN) "0.4"
set ::env(ECO_ENABLE) 1
set ::env(ECO_SKIP_PIN) 0

# Still seeing SEGVs in OpenROAD unless we disable diode insertion
set ::env(DIODE_INSERTION_STRATEGY) 0

set ::env(PL_ROUTABILITY_DRIVEN) 1
set ::env(PL_TIME_DRIVEN) 1

set ::env(SYNTH_STRATEGY) {DELAY 4}

# CTS tuning
set ::env(CTS_CLK_BUFFER_LIST) {sky130_fd_sc_hd__clkbuf_8 sky130_fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_2};
set ::env(CTS_DISABLE_POST_PROCESSING) 1
