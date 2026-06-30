# NDR 
add_ndr -width {Metal1 0.12 Metal2 0.14 Metal3 0.14 Metal4 0.14 Metal5 0.14 Metal6 0.14 Metal7 0.14 Metal8 0.14 Metal9 0.14 } -spacing {Metal1 0.12 Metal2 0.14 Metal3 0.14 Metal4 0.14 Metal5 0.14 Metal6 0.14 Metal7 0.14 Metal8 0.14 Metal9 0.14 } -name 2w2s

add_ndr -width {Metal1 0.12 Metal2 0.14 Metal3 0.14 Metal4 0.14 Metal5 0.14 Metal6 0.14 Metal7 0.14 Metal8 0.14 Metal9 0.14 } -spacing {Metal1 0.06 Metal2 0.07 Metal3 0.07 Metal4 0.07 Metal5 0.07 Metal6 0.07 Metal7 0.07 Metal8 0.07 Metal9 0.07 } -name 2w1s

add_ndr -width {Metal1 0.06 Metal2 0.07 Metal3 0.07 Metal4 0.07 Metal5 0.07 Metal6 0.07 Metal7 0.07 Metal8 0.07 Metal9 0.07 } -spacing {Metal1 0.06 Metal2 0.07 Metal3 0.07 Metal4 0.07 Metal5 0.07 Metal6 0.07 Metal7 0.07 Metal8 0.07 Metal9 0.07 } -name 1w1s

create_route_type -name clktop -non_default_rule 2w2s -bottom_preferred_layer Metal5 -top_preferred_layer Metal6
create_route_type -name clktrunk -non_default_rule 2w1s -bottom_preferred_layer Metal2 -top_preferred_layer Metal6
create_route_type -name clkleaf -non_default_rule 1w1s -bottom_preferred_layer Metal1 -top_preferred_layer Metal2

set_ccopt_property route_type clktop -net_type top
set_ccopt_property route_type clktrunk -net_type trunk
set_ccopt_property route_type clkleaf -net_type leaf

# Cell to used in clock path
set_ccopt_property buffer_cells {CLKBUFX4 CLKBUFX8 CLKBUFX12 CLKBUFX16}
set_ccopt_property inverter_cells {CLKINVX4 CLKINVX8 CLKINVX12}
#set_ccopt_property clock_gating_cells TLATNTSCA*
set_ccopt_property update_io_latency  false

# target skew and max_trans 
set_ccopt_property max_fanout 32 
set_clock_uncertainty -setup 0.250 [all_clocks]
set_clock_uncertainty -hold 0.125 [all_clocks]
set_ccopt_property target_max_trans 0.8
set_ccopt_property target_skew 0.11


# Routing Settings 
setNanoRouteMode -routeStrictlyHonorNonDefaultRule 2w2s
setNanoRouteMode -routeBottomRoutingLayer 1
setNanoRouteMode -routeTopRoutingLayer 7
setNanoRouteMode -routeWithTimingDriven true
setNanoRouteMode -routeWithSiDriven true
setNanoRouteMode -droutePostRouteSwapVia true 
setNanoRouteMode -drouteUseMultiCutViaEffort high

# Run CTS 
clock_opt_design -cts -expandedViews -out_dir ./reports/timingReports/ -prefix cts
saveDesign ./design/cts.enc

##################### Check Latency skew #################
 report_clock_timing -type latency -verbose
 report_clock_timing -type skew -verbose 

########### Min Pulse width check #########################
report_min_pulse_width  -violation_only


############# Timing Summary ##################################
timeDesign -expandedViews -postCTS -numPaths 10 -outDir ./reports/cts_opt -prefix cts_opt
timeDesign -expandedViews -postCTS -numPaths 10 -outDir ./reports/cts -prefix postcts_hold -hold 

## Post CTS optimization if violation exists
setOptMode -opt_skew_ccopt extreme  
optDesign -postCTS -expandedViews -outDir ./reports/cts_opt -prefix ctsopt 
optDesign -postCTS -expandedViews -outDir ./reports/cts_opt -prefix ctsopt_hold -hold