current_design $::env(MACRO)

create_clock -name $::env(CLOCK_PORT) -period 10.0000 [get_ports $::env(CLOCK_PORT)]
set_propagated_clock [all_clocks]
