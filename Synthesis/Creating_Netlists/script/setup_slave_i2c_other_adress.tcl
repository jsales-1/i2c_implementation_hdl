
set USER aluno6 ;
set PROJECT_DIR /prj/ci/workarea/${USER}/Verilog/i2c_implementation_hdl-main/Synthesis ;
set TECH_DIR /pdk/gpdk045 ;# technology dependent
set HDL_NAME "i2c_slave_controller"

set HDL_FILES ${PROJECT_DIR}/Creating_Netlists/RTL/i2c_slave_other_adress.sv 

set LIB_DIR ${TECH_DIR}/gsclib045_svt_v4.7/gsclib045/timing
#set LEF_DIR ${TECH_DIR}/gsclib045_svt_v4.7/gsclib045/lef

set WORST_LIST {slow_vdd1v0_basicCells.lib} 
set BEST_LIST {fast_vdd1v2_basicCells.lib} 
set LEF_LIST {gsclib045_tech.lef gsclib045_macro.lef}


#Set the search paths to the libraries and the HDL files
set_db hdl_search_path "${PROJECT_DIR}"

#set_db lib_search_path "${LIB_DIR} ${LEF_DIR}"
set_db lib_search_path "${LIB_DIR}"

set_db library "${BEST_LIST}"

read_hdl -sv ${HDL_FILES}

elaborate ${HDL_NAME} 

set_top_module ${HDL_NAME}

check_design -unresolved ${HDL_NAME}

read_sdc ${PROJECT_DIR}/Creating_Netlists/constraints/constraints.sdc

syn_generic ${HDL_NAME}

syn_map ${HDL_NAME} 

syn_opt

#################################
### Reports
#################################

report_timing > reports_slave_adress_h32/report_timing.rpt
report_power  > reports_slave_adress_h32/report_power.rpt
report_area   > reports_slave_adress_h32/report_area.rpt
report_qor    > reports_slave_adress_h32/report_qor.rpt

write_hdl > ${PROJECT_DIR}/Netlists/i2c_slave_controller_adress_h32.v
write_sdc > ${PROJECT_DIR}/Netlists/slave_sdc_dft_adress_h32.sdc
write_sdf -nonegchecks -edges check_edge -timescale ns -recrem split  -setuphold split > ${PROJECT_DIR}/Netlists/slave_delays_adress_h32.sdf
write_scandef > ${PROJECT_DIR}/Netlists/slave_scanDEF_adress_h32.scandef

