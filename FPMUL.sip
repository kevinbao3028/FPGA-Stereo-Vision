set_global_assignment -entity "FPMUL" -library "lib_FPMUL" -name IP_TOOL_NAME "altera_fp_functions"
set_global_assignment -entity "FPMUL" -library "lib_FPMUL" -name IP_TOOL_VERSION "20.1"
set_global_assignment -entity "FPMUL" -library "lib_FPMUL" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_FPMUL" -name SPD_FILE [file join $::quartus(sip_path) "FPMUL.spd"]

set_global_assignment -library "lib_FPMUL" -name MISC_FILE [file join $::quartus(sip_path) "FPMUL_sim/FPMUL.vo"]
