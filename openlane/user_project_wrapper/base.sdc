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

# There are two issues here:
# - RAM512 has hold violations in its design
# - Since OpenROAD can't produce timing information for macros (liberty files), the
#   paths to and from the macros are unconstrained. We need explicit constraints to
#   specify data in must change after the clock.
set ram512_delay 6
set_min_delay -to microwatt_0.soc0.bram.bram0.ram_0.memory_0/EN0* $ram512_delay
set_min_delay -to microwatt_0.soc0.bram.bram0.ram_0.memory_0/A0* $ram512_delay
set_min_delay -to microwatt_0.soc0.bram.bram0.ram_0.memory_0/Di0* $ram512_delay
set_min_delay -to microwatt_0.soc0.bram.bram0.ram_0.memory_0/WE0* $ram512_delay

set ram32_delay 5
set_min_delay -to microwatt_0.soc0.processor.dcache_0.rams:1.way.cache_ram_0/A0* $ram32_delay
set_min_delay -to microwatt_0.soc0.processor.dcache_0.rams:1.way.cache_ram_0/A1* $ram32_delay
set_min_delay -to microwatt_0.soc0.processor.dcache_0.rams:1.way.cache_ram_0/Di0* $ram32_delay
set_min_delay -to microwatt_0.soc0.processor.dcache_0.rams:1.way.cache_ram_0/EN0* $ram32_delay
set_min_delay -to microwatt_0.soc0.processor.dcache_0.rams:1.way.cache_ram_0/EN1* $ram32_delay
set_min_delay -to microwatt_0.soc0.processor.dcache_0.rams:1.way.cache_ram_0/WE0* $ram32_delay

set_min_delay -to microwatt_0.soc0.processor.icache_0.rams:1.way.cache_ram_0/A0* $ram32_delay
set_min_delay -to microwatt_0.soc0.processor.icache_0.rams:1.way.cache_ram_0/A1* $ram32_delay
set_min_delay -to microwatt_0.soc0.processor.icache_0.rams:1.way.cache_ram_0/Di0* $ram32_delay
set_min_delay -to microwatt_0.soc0.processor.icache_0.rams:1.way.cache_ram_0/EN0* $ram32_delay
set_min_delay -to microwatt_0.soc0.processor.icache_0.rams:1.way.cache_ram_0/EN1* $ram32_delay
set_min_delay -to microwatt_0.soc0.processor.icache_0.rams:1.way.cache_ram_0/WE0* $ram32_delay

set multiplier_delay 5
set_min_delay -to microwatt_0.soc0.processor.execute1_0.multiply_0.multiplier/a $multiplier_delay
set_min_delay -to microwatt_0.soc0.processor.execute1_0.multiply_0.multiplier/b $multiplier_delay
set_min_delay -to microwatt_0.soc0.processor.execute1_0.multiply_0.multiplier/c $multiplier_delay

set_min_delay -to microwatt_0.soc0.processor.with_fpu.fpu_0.fpu_multiply_0.multiplier/a $multiplier_delay
set_min_delay -to microwatt_0.soc0.processor.with_fpu.fpu_0.fpu_multiply_0.multiplier/b $multiplier_delay
set_min_delay -to microwatt_0.soc0.processor.with_fpu.fpu_0.fpu_multiply_0.multiplier/c $multiplier_delay

set register_file_delay 5
set_min_delay -to microwatt_0.soc0.processor.register_file_0.register_file_0/R1 $register_file_delay
set_min_delay -to microwatt_0.soc0.processor.register_file_0.register_file_0/R2 $register_file_delay
set_min_delay -to microwatt_0.soc0.processor.register_file_0.register_file_0/R3 $register_file_delay
set_min_delay -to microwatt_0.soc0.processor.register_file_0.register_file_0/RW $register_file_delay
set_min_delay -to microwatt_0.soc0.processor.register_file_0.register_file_0/DW $register_file_delay
set_min_delay -to microwatt_0.soc0.processor.register_file_0.register_file_0/WE $register_file_delay

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
