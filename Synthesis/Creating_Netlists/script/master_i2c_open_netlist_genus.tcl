####################################################################
# Script: read_netlist_and_gui.tcl
# Descrição: Script para ler a netlist sintetizada e abrir o GUI_SHOW
####################################################################

# Configurações do usuário e diretórios
set USER aluno6
set PROJECT_DIR /prj/ci/workarea/${USER}/Verilog/i2c_implementation_hdl-main/Synthesis
set TECH_DIR /pdk/gpdk045

# Nome do design e arquivos
set HDL_NAME "i2c_master_controller"
set NETLIST_FILE ${PROJECT_DIR}/Netlists/i2c_master_controller.v
set LIB_DIR ${TECH_DIR}/gsclib045_svt_v4.7/gsclib045/timing
set BEST_LIST {fast_vdd1v2_basicCells.lib}

# Configurar paths
set_db lib_search_path "${LIB_DIR}"
set_db library "${BEST_LIST}"


read_hdl -v2001 ${NETLIST_FILE}

elaborate ${HDL_NAME}

check_design -unresolved ${HDL_NAME}

gui_show
