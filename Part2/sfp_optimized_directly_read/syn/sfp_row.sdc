set clock_cycle 1
set io_delay 0.2

set clock_port clk

# Clock definition
create_clock -name clk -period $clock_cycle [get_ports $clock_port]

set_input_delay -clock [get_clocks clk] -add_delay -max $io_delay [all_inputs]

set_output_delay -clock [get_clocks clk] -add_delay $io_delay [all_outputs]


#for {set i 0} {$i < 30} {incr i} {
set_multicycle_path -setup 2 -from sfp_in[*] -to sum_q_reg_*_

set_multicycle_path -hold 1 -from sfp_in[*] -to sum_q_reg_*_

set_multicycle_path -setup 2 -from sfp_in[*] -to sfp_out_sign*_reg_*_

set_multicycle_path -hold 1 -from sfp_in[*] -to sfp_out_sign*_reg_*_



