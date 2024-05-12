set_global_assignment -entity "clock_143" -library "lib_clock_143" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "clock_143" -library "lib_clock_143" -name IP_TOOL_VERSION "21.1"
set_global_assignment -entity "clock_143" -library "lib_clock_143" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_clock_143" -name SPD_FILE [file join $::quartus(sip_path) "clock_143.spd"]

set_global_assignment -library "lib_clock_143" -name MISC_FILE [file join $::quartus(sip_path) "clock_143_sim/clock_143.vo"]
