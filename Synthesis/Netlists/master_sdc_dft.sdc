# ####################################################################

#  Created by Genus(TM) Synthesis Solution 22.16-s078_1 on Wed Mar 18 18:16:42 -03 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design i2c_master_controller

create_clock -name "clock" -period 10.0 -waveform {0.0 5.0} [get_ports clk]
set_clock_gating_check -setup 0.0 
set_wire_load_mode "enclosed"
