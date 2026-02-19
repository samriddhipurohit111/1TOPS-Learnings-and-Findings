#######################################
#         RTL DFT SYNTHESIS SCRIPT    #
#######################################
# WARNING: This is the dft synthesis script whereby scanchain insertions happen. 
# For normal synthesis use synthesis.tcl; for scan chain based use this script!

# Prerequisites are:
# 1) First make the desired project folder
# 2) Make 5 folders inside it named "constraint", "outputs", "reports", "rtl", "scripts"
# 3) Write the codes within respective folders 
# 4) Make changes to this tcl file wherever needed
# 5) Open cadence, enter genus
# 6) Write "source scripts/dftsynthesis.tcl" and it will auto execute and gui will open 
# 7) The needed output files will get saved in the outputs folder
# 8) Similarly the needed reports will get saved in the reports folder

#--------------------------------------
# Directory Setup
#--------------------------------------
file mkdir reports
file mkdir outputs

#-------------------------------------
# 1. Read Technology Library
#-------------------------------------
read_lib /home/install/FOUNDRY/digital/180nm/dig/lib/slow.lib

#-------------------------------------
# 2. Read RTL
#-------------------------------------
read_hdl rtl/counter.v

#-------------------------------------
# 3. Elaborate Design
#-------------------------------------
elaborate counter
check_design -unresolved > reports/check_design.rpt

#-------------------------------------
# 4. Read Constraints
#-------------------------------------
read_sdc constraint/constraint.sdc

#### scan_chain_insertion_part1
check_dft_rules
set_db dft_scan_style muxed_scan
define_shift_enable -name SE -active high -create_port SE -default

### synthesis step
syn_generic
syn_map
syn_opt

#### scan_chain_insertion_part2
set_db design:counter .dft_min_number_of_scan_chains 1
define_scan_chain -name top_chain -sdi scan_ff_in -sdo scan_ff_out -create_port
connect_scan_chains -auto_create_chains
report_scan_chains > reports/scan_chain.rpt

##### write_file
# Ensure scan chains are fully connected before writing outputs
connect_scan_chains -auto_create_chains
write_hdl > outputs/counter_dft_net.v
write_sdc > outputs/constraint_dft_out.sdc
write_scandef > outputs/counter.scandef

### generate report
report_area   > reports/area_dft.rpt
report_power  > reports/power_dft.rpt
report_timing > reports/timing_dft.rpt
report_gates  > reports/gates_dft.rpt

#-------------------------------------
# 8. GUI
#-------------------------------------
gui_show
#-------------------------------------