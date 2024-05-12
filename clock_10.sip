set_global_assignment -entity "clock_10" -library "lib_clock_10" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "clock_10" -library "lib_clock_10" -name IP_TOOL_VERSION "21.1"
set_global_assignment -entity "clock_10" -library "lib_clock_10" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_clock_10" -name SPD_FILE [file join $::quartus(sip_path) "clock_10.spd"]

set_global_assignment -library "lib_clock_10" -name MISC_FILE [file join $::quartus(sip_path) "clock_10_sim/clock_10.vo"]
