## genus -f genus_script.tcl
set DESIGN mac_Nbits

set_db init_hdl_search_path ../rtl
set_db init_lib_search_path ../gpdk045_workspace/gsclib045_all_v4.4/gsclib045/timing

read_libs { slow_vdd1v0_basicCells.lib }

read_hdl mac_Nbits.v

elaborate

read_sdc ../constraints/constraints.sdc

set_db syn_generic_effort medium
syn_generic

report_area > reports/report_area_generic.rpt
report_timing > reports/report_timing_generic.rpt
report_power > reports/report_power_generic.rpt

set_db syn_map_effort medium
syn_map

report_area > reports/report_area_map.rpt
report_timing > reports/report_timing_map.rpt
report_power > reports/report_power_map.rpt

set_db syn_opt_effort medium
syn_opt

report_area > reports/report_area_opt.rpt
report_timing > reports/report_timing_opt.rpt
report_power > reports/report_power_opt.rpt

#Outputs
write_hdl > outputs/mac_netlist.v
write_sdc > outputs/mac_netlist_constraints.sdc
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge  -setuphold split > outputs/delays.sdf
