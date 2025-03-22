set clock_cycle 1 
set io_delay 0.2 

set clock_port CLK

# Clock definition
create_clock -name CLK -period $clock_cycle [get_ports $clock_port]

# Input delays (0.2ns relative to clock)
set_input_delay -clock [get_clocks CLK] -add_delay -max $io_delay [get_ports {D[*]}]
set_input_delay -clock [get_clocks CLK] -add_delay -max $io_delay [get_ports {A[*]}]
set_input_delay -clock [get_clocks CLK] -add_delay -max $io_delay [get_ports {CEN}]
set_input_delay -clock [get_clocks CLK] -add_delay -max $io_delay [get_ports {WEN}]

# Output delays (0.2ns relative to clock)
set_output_delay -clock [get_clocks CLK] -add_delay -max $io_delay [get_ports {Q[*]}]
