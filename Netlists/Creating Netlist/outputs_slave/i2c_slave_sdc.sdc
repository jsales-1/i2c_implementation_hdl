# ####################################################################

#  Created by Genus(TM) Synthesis Solution 22.16-s078_1 on Thu Mar 05 18:57:06 -03 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design i2c_slave_controller

set_clock_gating_check -setup 0.0 
set_wire_load_mode "enclosed"
