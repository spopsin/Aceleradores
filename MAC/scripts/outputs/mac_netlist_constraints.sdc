# ####################################################################

#  Created by Genus(TM) Synthesis Solution 23.12-s086_1 on Mon Sep 22 11:09:22 -03 2025

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design mac_Nbits

create_clock -name "clock" -period 10.0 -waveform {0.0 5.0} [get_ports clk]
set_clock_gating_check -setup 0.0 
set_wire_load_mode "enclosed"
