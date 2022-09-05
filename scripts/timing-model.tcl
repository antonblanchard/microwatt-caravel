read_liberty $::env(PDK_ROOT)/$::env(PDK)/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog verilog/gl/$::env(MACRO).v
link_design $::env(MACRO)
read_spef spef/$::env(MACRO).spef
#read_sdc sdc/$::env(MACRO).sdc
read_sdc scripts/timing-model.sdc
set_propagated_clock [all_clocks]

write_timing_model user_project_wrapper/lib/$:::env(MACRO).lib

exit
