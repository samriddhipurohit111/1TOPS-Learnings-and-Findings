setNanoRouteMode -reset
setNanoRouteMode -route_detail_auto_stop true

# Set layers
setDesignMode -bottomRoutingLayer 1
setDesignMode -topRoutingLayer 7 
 
# Enable SI driven and timing driven routing 
setNanoRouteMode -route_with_si_driven true -route_with_timing_driven true

# Enable fixing (layer hopping or Antenna diode) 
setNanoRouteMode -route_detail_fix_antenna true
# setNanoRouteMode -route_antenna_diode_insertion true
#  setNanoRouteMode -route_antenna_cell_name ANTENNA

# Enable options for multicut vias 
setNanoRouteMode -route_reserve_space_for_multi_cut true
setNanoRouteMode -route_detail_post_route_swap_via true

## Run Routing 
routeDesign -globalDetail


# Perform Via optimization 
setNanoRouteMode -route_detail_post_route_swap_via true
setNanoRouteMode -route_detail_use_multi_cut_via_effort high
setNanoRouteMode -route_with_eco true
routeDesign -viaOpt

# Wire Optimization 
setNanoRouteMode -route_detail_post_route_swap_via none
setNanoRouteMode -route_detail_post_route_spread_wire true
setNanoRouteMode -route_detail_post_route_wire_widen true
setNanoRouteMode -route_detail_min_length_for_spread_wire 2
routeDesign -wireOpt 
saveDesign ./design/route.enc


# Check opens or unconnected nets 
verifyConnectivity 
# To fix open nets 
ecoRoute 

# Checks Shorts 
verify_drc -check_short_only -limit 0


# Check DRC 
 verify_drc -limit 0

# Fix DRC and Antenna 
setNanoRouteMode -route_with_eco true
setNanoRouteMode -route_antenna_diode_insertion true
setNanoRouteMode -route_antenna_cell_name ANTENNA
editDelete -regular_wire_with_drc
# setDesignMode -topRoutingLayer 8
ecoRoute



# Report Timing 
setAnalysisMode -analysisType onChipVariation
timeDesign -postRoute -prefix  route_setup -outDir ./outputs/route -expandedViews
timeDesign -postRoute -prefix  route_hold -outDir ./outputs/route -expandedViews -hold


# RC extraction
setDesignMode -process 45 
 create_rc_corner -name rc_max -cap_table {../../RAK_floorplanning_23.1/libs/captbl/worst/capTable} -preRoute_res {1.0} -preRoute_cap {1.0} -preRoute_clkres {0.0} -preRoute_clkcap {0.0} -postRoute_res {1.0} -postRoute_cap {1.0} -postRoute_xcap {1.0} -postRoute_clkres {0.0} -postRoute_clkcap {0.0} -qx_tech_file ../../RAK_floorplanning_23.1/libs/qx/qrcTechFile

create_rc_corner -name rc_min -cap_table {../../RAK_floorplanning_23.1/libs/captbl/best/capTable} -preRoute_res {1.0} -preRoute_cap {1.0} -preRoute_clkres {0.0} -preRoute_clkcap {0.0} -postRoute_res {1.0} -postRoute_cap {1.0} -postRoute_xcap {1.0} -postRoute_clkres {0.0} -postRoute_clkcap {0.0} -qx_tech_file ../../RAK_floorplanning_23.1/libs/qx/qrcTechFile

extractRC
rcOut -rc_corner rc_max  -spef ./spef/rc_max.spef
rcOut -rc_corner rc_min  -spef ./spef/rc_min.spef

spefIn ./spef/rc_max.spef -rc_corner rc_max
spefIn ./spef/rc_min.spef  -rc_corner rc_min

# Dump Netlist
saveNetlist ./outputs/chip_top.v
defOut ./outputs/chip_top.def 

# Update SDC 
create_constraint_mode -name func -sdc_files ./inputs/chip_top.sdc
update_analysis_view -constraint_mode func -name  func_worst
update_analysis_view -constraint_mode func -name  func_best

# Fix Timing 
optDesign -postRoute -expandedViews -outDir ./reports/route_opt -prefix routeopt 
optDesign -postRoute -expandedViews -outDir ./reports/route_opt -prefix routeopt_hold -hold

# Source back ECO 
source ./../sta/old_eco.tcl 
setDesignMode -topRoutingLayer 8
ecoRoute