set_global_assignment -entity "clock_165" -library "lib_clock_165" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "clock_165" -library "lib_clock_165" -name IP_TOOL_VERSION "21.1"
set_global_assignment -entity "clock_165" -library "lib_clock_165" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_clock_165" -name SPD_FILE [file join $::quartus(sip_path) "clock_165.spd"]

set_global_assignment -library "lib_clock_165" -name MISC_FILE [file join $::quartus(sip_path) "clock_165_sim/clock_165.vo"]
