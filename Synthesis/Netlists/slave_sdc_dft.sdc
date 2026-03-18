# ####################################################################

#  Created by Genus(TM) Synthesis Solution 22.16-s078_1 on Wed Mar 18 18:09:35 -03 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design i2c_slave_controller

set_clock_gating_check -setup 0.0 
set_wire_load_mode "enclosed"
