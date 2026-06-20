create_route_type -name clktop -bottom_preferred_layer Metal5 -top_preferred_layer Metal6
create_route_type -name clktrunk  -bottom_preferred_layer Metal2 -top_preferred_layer Metal6
create_route_type -name clkleaf  -bottom_preferred_layer Metal1 -top_preferred_layer Metal2

set_ccopt_property route_type clktop -net_type top
set_ccopt_property route_type clktrunk -net_type trunk
set_ccopt_property route_type clkleaf -net_type leaf

# Cell to used in clock path
set_ccopt_property buffer_cells {CLKBUFX4 CLKBUFX8 CLKBUFX12 CLKBUFX16}
set_ccopt_property inverter_cells {CLKINVX4 CLKINVX8 CLKINVX12}
set_ccopt_property update_io_latency  false

# target skew and max_trans 
set_ccopt_property max_fanout 32 
set_clock_uncertainty -setup 0.125 [all_clocks]
set_clock_uncertainty -hold 0.125 [all_clocks]
set_ccopt_property target_max_trans 0.8
set_ccopt_property target_skew 0.11


# Routing Settings 
setNanoRouteMode -routeBottomRoutingLayer 1
setNanoRouteMode -routeTopRoutingLayer 7

# Run CTS 
ccopt_design -cts -expandedViews -outDir ./reports/timingReports/ -prefix cts
saveDesign ./design/cts.enc

##################### Check Latency skew #################
 report_clock_timing -type latency -verbose
 report_clock_timing -type skew -source -late -max 0 -verbose 

########### Min Pulse width check #########################
report_min_pulse_width  -violation_only


############# Timing Summary ##################################
timeDesign -expandedViews -postCTS -numPaths 10 -outDir ./reports/cts_opt -prefix cts_opt
timeDesign -expandedViews -postCTS -numPaths 10 -outDir ./reports/cts_hold -prefix postcts_hold -hold 

## Post CTS optimization if violation exists
setOptMode -opt_skew_ccopt extreme  
optDesign -postCTS -expandedViews -outDir ./reports/cts_opt -prefix ctsopt 
optDesign -postCTS -expandedViews -outDir ./reports/cts_opt -prefix ctsopt_hold -hold
