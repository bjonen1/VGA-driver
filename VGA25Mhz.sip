set_global_assignment -entity "VGA25Mhz" -library "lib_VGA25Mhz" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "VGA25Mhz" -library "lib_VGA25Mhz" -name IP_TOOL_VERSION "16.0"
set_global_assignment -entity "VGA25Mhz" -library "lib_VGA25Mhz" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_VGA25Mhz" -name SPD_FILE [file join $::quartus(sip_path) "VGA25Mhz.spd"]

set_global_assignment -library "lib_VGA25Mhz" -name MISC_FILE [file join $::quartus(sip_path) "VGA25Mhz_sim/VGA25Mhz.vo"]
