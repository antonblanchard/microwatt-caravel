create_clock [get_ports $::env(CLOCK_PORT)]  -name $::env(CLOCK_PORT) -period $::env(CLOCK_PERIOD)
set_propagated_clock [get_clocks $::env(CLOCK_PORT)]

set input_delay_value [expr $::env(CLOCK_PERIOD) * $::env(IO_PCT)]
set output_delay_value [expr $::env(CLOCK_PERIOD) * $::env(IO_PCT)]
puts "\[INFO\]: Setting output delay to: $output_delay_value"
puts "\[INFO\]: Setting input delay to: $input_delay_value"

set_max_fanout $::env(SYNTH_MAX_FANOUT) [current_design]

# Should we create a virtual clock to constrain this?
set_input_delay $input_delay_value -clock [get_clocks $::env(CLOCK_PORT)] -add_delay [get_ports {io_in[5]}]
set_output_delay $output_delay_value -clock [get_clocks $::env(CLOCK_PORT)] -add_delay [get_ports {io_out[6]}]

# Synchronous reset
set_input_delay $input_delay_value -clock [get_clocks $::env(CLOCK_PORT)] -add_delay [get_ports {io_in[7]}]

# SPI
set_output_delay $output_delay_value -clock [get_clocks $::env(CLOCK_PORT)] -add_delay [get_ports {io_out[8]}]
set_output_delay $output_delay_value -clock [get_clocks $::env(CLOCK_PORT)] -add_delay [get_ports {io_out[9]}]
set_output_delay $output_delay_value -clock [get_clocks $::env(CLOCK_PORT)] -add_delay [get_ports {io_out[10]}]
set_input_delay $input_delay_value -clock [get_clocks $::env(CLOCK_PORT)] -add_delay [get_ports {io_in[11]}]

# JTAG on its own clock domain
create_clock -name jtag_clk -period 100 [get_ports {io_in[14]}] 
set_clock_transition 0.1500 [get_clocks jtag_clk]
set_clock_uncertainty 0.2500 jtag_clk
set_propagated_clock [get_clocks jtag_clk]
set_output_delay 10 -clock [get_clocks jtag_clk] -add_delay [get_ports {io_out[12]}]
set_input_delay 10 -clock [get_clocks jtag_clk] -add_delay [get_ports {io_in[13]}]
set_input_delay 10 -clock [get_clocks jtag_clk] -add_delay [get_ports {io_in[15]}]
set_clock_groups -name group1 -logically_exclusive \
    -group [get_clocks jtag_clk]\
    -group [get_clocks $::env(CLOCK_PORT)]

# GPIOs/external bus
foreach i {0 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 36 37} {
    set_input_delay $input_delay_value -clock [get_clocks $::env(CLOCK_PORT)] -add_delay [get_ports io_in[$i]]
    set_output_delay $output_delay_value -clock [get_clocks $::env(CLOCK_PORT)] -add_delay [get_ports io_out[$i]]
    set_output_delay $output_delay_value -clock [get_clocks $::env(CLOCK_PORT)] -add_delay [get_ports io_oeb[$i]]
}

# Alt reset
set_input_delay $input_delay_value -clock [get_clocks $::env(CLOCK_PORT)] -add_delay [get_ports io_in[35]]

# To avoid check_setup complaining about unused ports, add some arbitrary constraints

# Unused bidirectional ports
foreach i {analog_io*} {
    set_input_delay 0.1 -clock [get_clocks $::env(CLOCK_PORT)] -add_delay [get_ports $i]
    set_output_delay 0.1 -clock [get_clocks $::env(CLOCK_PORT)] -add_delay [get_ports $i]
}

# Unused output ports
foreach i {la_data_out* user_irq* wbs_ack_o wbs_dat_o*} {
    set_output_delay 0.1 -clock [get_clocks $::env(CLOCK_PORT)] -add_delay [get_ports $i]
}

# Unused input ports
foreach i {la_data_in* la_oenb* wb_clk_i wb_rst_i wbs_stb_i wbs_cyc_i wbs_we_i wbs_sel_i* wbs_dat_i* wbs_adr_i*} {
    set_input_delay 0.1 -clock [get_clocks $::env(CLOCK_PORT)] -add_delay [get_ports $i]
}

# Unused GPIOs
foreach i {1 2 3 4} {
    set_input_delay 0.1 -clock [get_clocks $::env(CLOCK_PORT)] -add_delay [get_ports io_in[$i]]
    set_output_delay 0.1 -clock [get_clocks $::env(CLOCK_PORT)] -add_delay [get_ports io_out[$i]]
    set_output_delay 0.1 -clock [get_clocks $::env(CLOCK_PORT)] -add_delay [get_ports io_oeb[$i]]
}

# Unused GPIO outputs
foreach i {6 8 9 10 12} {
    set_input_delay 0.1 -clock [get_clocks $::env(CLOCK_PORT)] -add_delay [get_ports io_in[$i]]
    set_output_delay 0.1 -clock [get_clocks $::env(CLOCK_PORT)] -add_delay [get_ports io_oeb[$i]]
}

# Unused GPIO inputs
foreach i {5 7 11 13 14 15 35} {
    set_output_delay 0.1 -clock [get_clocks $::env(CLOCK_PORT)] -add_delay [get_ports io_out[$i]]
    set_output_delay 0.1 -clock [get_clocks $::env(CLOCK_PORT)] -add_delay [get_ports io_oeb[$i]]
}

# TODO set this as parameter
set_driving_cell -lib_cell $::env(SYNTH_DRIVING_CELL) -pin $::env(SYNTH_DRIVING_CELL_PIN) [all_inputs]
set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]

puts "\[INFO\]: Setting clock uncertainity to: $::env(SYNTH_CLOCK_UNCERTAINITY)"
set_clock_uncertainty $::env(SYNTH_CLOCK_UNCERTAINITY) [get_clocks $::env(CLOCK_PORT)]

puts "\[INFO\]: Setting clock transition to: $::env(SYNTH_CLOCK_TRANSITION)"
set_clock_transition $::env(SYNTH_CLOCK_TRANSITION) [get_clocks $::env(CLOCK_PORT)]

puts "\[INFO\]: Setting timing derate to: [expr {$::env(SYNTH_TIMING_DERATE) * 10}] %"
set_timing_derate -early [expr {1-$::env(SYNTH_TIMING_DERATE)}]
set_timing_derate -late [expr {1+$::env(SYNTH_TIMING_DERATE)}]
