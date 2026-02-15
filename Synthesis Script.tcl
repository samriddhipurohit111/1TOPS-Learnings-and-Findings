#Prerequisites are:
#1) First make the desired project folder
#2) Make 5 folders inside it named "constraint", "outputs", "reports", "rtl" , "scripts"
#3) Write the codes within respective folders 
#4) Make changes to this tcl file wherever needed
#5) Open cadence , enter genus
#6) Write "Source scripts/synthesis.tcl" and it will auto execute and gui will open 
#7) The needed output files will get saved in the output folder
#8) Similarly the needed reports will get saved in the reports folder



#######################################
#         RTL SYNTHESIS SCRIPT        #
#######################################

#--------------------------------------
# Directory Setup
#--------------------------------------
file mkdir reports
file mkdir outputs

#-------------------------------------
# 1. Read Technology Library (change only if the type of lib has to be changed)
#-------------------------------------
read_lib /home/install/FOUNDRY/digital/180nm/dig/lib/slow.lib
#-------------------------------------

#-------------------------------------
# 2. Read RTL (make changes here)
#-------------------------------------
read_hdl rtl/mod10counter.v
#-------------------------------------

#-------------------------------------
# 3. Elaborate Design(make changes here with the module name only)
#-------------------------------------
elaborate mod10counter
check_design -unresolved > reports/check_design.rpt
#-------------------------------------

#-------------------------------------
# 4. Read Constraints (no need to change if the name is constraints only)
#-------------------------------------
read_sdc constraint/constraint.sdc

#Constraint sanity

report_clocks > reports/clocks.rpt
report_timing -lint > reports/timing_lint.rpt

#--------------------------------------
# 5. Synthesis Flow
#-------------------------------------
syn_generic
syn_map
syn_opt

#-------------------------------------
# 6. Write Golden Outputs
#-------------------------------------
write_hdl > outputs/top_module_netlist.v
write_sdc > outputs/top_module_constraints.sdc

#-------------------------------------
# 7. Analysis Reports(Will be used further for other tools)
#-------------------------------------

# Area
report_area > reports/area.rpt

#Power
report_power > reports/power.rpt

#Timing
report_timing > reports/timing_max.rpt
report_qor > reports/cells.rpt

#-------------------------------------
# 8. GUI
gui_show
#------------------------------------