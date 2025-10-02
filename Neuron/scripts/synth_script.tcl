set DESIGN neuron_Nbits

set FILES neuron_Nbits.v

set_db init_hdl_search_path ../rtl

set_db syn_generic_effort high
set_db syn_map_effort high
set_db syn_opt_effort high

#set_db timing_report_unconstrained true

read_libs { /pdk/cadence/gpdk045/gsclib045_all_v4.4/gsclib045/timing/slow_vdd1v0_basicCells.lib /pdk/cadence/gpdk045/gsclib045_all_v4.4/gsclib045/timing/slow_vdd1v0_extvdd1v0.lib /pdk/cadence/gpdk045/gsclib045_all_v4.4/gsclib045/timing/slow_vdd1v0_multibitsDFF.lib }

read_physical -lef { /pdk/cadence/gpdk045/gsclib045_all_v4.4/gsclib045/lef/gsclib045_macro.lef /pdk/cadence/gpdk045/gsclib045_all_v4.4/gsclib045/lef/gsclib045_multibitsDFF.lef /pdk/cadence/gpdk045/gsclib045_all_v4.4/gsclib045/lef/gsclib045_tech.lef }

read_hdl -sv $FILES

elaborate $DESIGN

read_sdc ../constraints/constraints.sdc

init_design

syn_generic

report_area > reports/report_area_generic.rpt
report_timing > reports/report_timing_generic.rpt
report_power > reports/report_power_generic.rpt

syn_map

report_area > reports/report_area_map.rpt
report_timing > reports/report_timing_map.rpt
report_power > reports/report_power_map.rpt

#foreach cg [vfind / -cost_group *] {
#  report_timing -cost_group [list $cg] > reports/${DESIGN}_[vbasename $cg]_post_map.rpt
#}

syn_opt

# Gera reports para o pior caso
# set_analysis_view -setup worst_view -hold worst_view
 report_area > reports_ss/report_area_opt.rpt
 report_timing > reports_ss/report_timing_opt.rpt
 report_power > reports_ss/report_power_opt.rpt
 report_gates -power > reports/${DESIGN}_gates_power.log
 report_dp > reports/${DESIGN}_datapath_incr.log
 report_messages > reports/${DESIGN}_messages.log
 write_snapshot -outdir reports -tag final
 report_summary -directory reports

#Outputs
write_hdl > outputs/mac_netlist.v
write_sdc > outputs/mac_netlist_constraints.sdc
#write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge  -setuphold split > outputs/delays.sdf
#write_scandef > outputs/scan_chain.def
#write_design -innovus -base_name ../innovus/${DESIGN}






