set_global_assignment -entity "clock_166" -library "lib_clock_166" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "clock_166" -library "lib_clock_166" -name IP_TOOL_VERSION "21.1"
set_global_assignment -entity "clock_166" -library "lib_clock_166" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_clock_166" -name SPD_FILE [file join $::quartus(sip_path) "clock_166.spd"]

set_global_assignment -library "lib_clock_166" -name MISC_FILE [file join $::quartus(sip_path) "clock_166_sim/clock_166.vo"]
