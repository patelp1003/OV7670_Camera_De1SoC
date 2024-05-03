# Invoke as
#
# quartus_sh -t de1-soc-project.tcl

# $moduleName.sv should include a module named $moduleName

set moduleName "top_module"
set systemVerilogSource "asyn_fifo.v camera_interface.v i2c_top.v sdram_controller.v ${moduleName}.v debounce_explicit.v vga_core.v vga_interface.v sdcard_interface.v"

project_new $moduleName -overwrite

foreach {name value} {
    FAMILY "Cyclone V"
    DEVICE 5CSEMA5F31C6
    PROJECT_OUTPUT_DIRECTORY output_files
    MIN_CORE_JUNCTION_TEMP 0
    MAX_CORE_JUNCTION_TEMP 85
    CYCLONEII_RESERVE_NCEO_AFTER_CONFIGURATION "USE AS REGULAR IO"
    NUM_PARALLEL_PROCESSORS 4
} { set_global_assignment -name $name $value }

set_global_assignment -name TOP_LEVEL_ENTITY $moduleName

foreach filename $systemVerilogSource {
    set_global_assignment -name SYSTEMVERILOG_FILE $filename
}

foreach {port pin} {    
    clk PIN_AF14

    
    key[0] PIN_AA14
    key[1] PIN_AA15
    key[2] PIN_W15
    key[3] PIN_Y16

    rst_n PIN_AB12
    SW[1] PIN_AC12
    SW[2] PIN_AF9 
    SW[3] PIN_AF10
    SW[4] PIN_AD11
    SW[5] PIN_AD12
    SW[6] PIN_AE11
    SW[7] PIN_AC9 
    SW[8] PIN_AD10
    SW[9] PIN_AE12

    LEDR[0] PIN_V16
    LEDR[1] PIN_W16
    LEDR[2] PIN_V17
    LEDR[3] PIN_V18
    LEDR[4] PIN_W17
    LEDR[5] PIN_W19
    LEDR[6] PIN_Y19
    LEDR[7] PIN_W20
    LEDR[8] PIN_W21
    LEDR[9] PIN_Y21

    HEX0[0] PIN_AE26 
    HEX0[1] PIN_AE27 
    HEX0[2] PIN_AE28 
    HEX0[3] PIN_AG27 
    HEX0[4] PIN_AF28 
    HEX0[5] PIN_AG28 
    HEX0[6] PIN_AH28
    
    HEX1[0] PIN_AJ29 
    HEX1[1] PIN_AH29 
    HEX1[2] PIN_AH30 
    HEX1[3] PIN_AG30 
    HEX1[4] PIN_AF29 
    HEX1[5] PIN_AF30 
    HEX1[6] PIN_AD27
    
    HEX2[0] PIN_AB23 
    HEX2[1] PIN_AE29 
    HEX2[2] PIN_AD29 
    HEX2[3] PIN_AC28 
    HEX2[4] PIN_AD30 
    HEX2[5] PIN_AC29 
    HEX2[6] PIN_AC30
    
    HEX3[0] PIN_AD26 
    HEX3[1] PIN_AC27 
    HEX3[2] PIN_AD25 
    HEX3[3] PIN_AC25 
    HEX3[4] PIN_AB28 
    HEX3[5] PIN_AB25 
    HEX3[6] PIN_AB22
    
    HEX4[0] PIN_AA24 
    HEX4[1] PIN_Y23  
    HEX4[2] PIN_Y24  
    HEX4[3] PIN_W22  
    HEX4[4] PIN_W24  
    HEX4[5] PIN_V23  
    HEX4[6] PIN_W25
    
    HEX5[0] PIN_V25  
    HEX5[1] PIN_AA28 
    HEX5[2] PIN_Y27  
    HEX5[3] PIN_AB27 
    HEX5[4] PIN_AB26 
    HEX5[5] PIN_AA26 
    HEX5[6] PIN_AA25

    GPIO_1[0] PIN_AB17 	     
    GPIO_1[1] PIN_AA21 
    GPIO_1[2] PIN_AB21 
    GPIO_1[3] PIN_AC23 	     
    GPIO_1[4] PIN_AD24 	     
    GPIO_1[5] PIN_AE23 	     
    GPIO_1[6] PIN_AE24 	     
    GPIO_1[7] PIN_AF25 	     
    GPIO_1[8] PIN_AF26 	     
    GPIO_1[9] PIN_AG25 	     
    GPIO_1[10] PIN_AG26 	     
    GPIO_1[11] PIN_AH24 	     
    GPIO_1[12] PIN_AH27 	     
    GPIO_1[13] PIN_AJ27 	     
    GPIO_1[14] PIN_AK29  	     
    GPIO_1[15] PIN_AK28 	     
    GPIO_1[16] PIN_AK27 	     
    GPIO_1[17] PIN_AJ26 	       
    GPIO_1[18] PIN_AK26 	     
    GPIO_1[19] PIN_AH25 	     
    GPIO_1[20] PIN_AJ25 	     
    GPIO_1[21] PIN_AJ24 	     
    GPIO_1[22] PIN_AK24 	     
    GPIO_1[23] PIN_AG23 	     
    GPIO_1[24] PIN_AK23 	     
    GPIO_1[25] PIN_AH23 	     
    GPIO_1[26] PIN_AK22 	     
    GPIO_1[27] PIN_AJ22 	     
    GPIO_1[28] PIN_AH22 	     
    GPIO_1[29] PIN_AG22 	     
    GPIO_1[30] PIN_AF24 	     
    GPIO_1[31] PIN_AF23 	     
    GPIO_1[32] PIN_AE22 	     
    GPIO_1[33] PIN_AD21 	     
    GPIO_1[34] PIN_AA20 	     
    GPIO_1[35] PIN_AC22    

    cmos_scl PIN_AC18 	     
    cmos_sda PIN_Y17  
    cmos_vsync PIN_AD17     
    cmos_href PIN_Y18  	     
    cmos_pclk PIN_AK16 	     
    cmos_xclk PIN_AK18 	     
    cmos_db[7] PIN_AK19 	     
    cmos_db[6] PIN_AJ19 	     
    cmos_db[5] PIN_AJ17      
    cmos_db[4] PIN_AJ16 	         
    cmos_db[3] PIN_AH18   
    cmos_db[2] PIN_AH17      
    cmos_db[1] PIN_AG16    
    cmos_db[0] PIN_AE16    
    cmos_rst_n PIN_AF16      
    cmos_pwdn PIN_AG17 	     
    GPIO_0[16] PIN_AA18 	     
    GPIO_0[17] PIN_AA19 	     
    GPIO_0[18] PIN_AE17 
    GPIO_0[19] PIN_AC20 
    GPIO_0[20] PIN_AH19 	     
    GPIO_0[21] PIN_AJ20 	     
    GPIO_0[22] PIN_AH20 	     
    GPIO_0[23] PIN_AK21 	     
    GPIO_0[24] PIN_AD19 	     
    GPIO_0[25] PIN_AD20 	     
    GPIO_0[26] PIN_AE18 	     
    GPIO_0[27] PIN_AE19 	     
    GPIO_0[28] PIN_AF20 	     
    GPIO_0[29] PIN_AF21 	     
    GPIO_0[30] PIN_AF19 	     
    GPIO_0[31] PIN_AG21 	     
    GPIO_0[32] PIN_AF18 	     
    GPIO_0[33] PIN_AG20 	     
    GPIO_0[34] PIN_AG18 	     
    GPIO_0[35] PIN_AJ21 

    sdram_addr[0] PIN_AK14     
    sdram_addr[1] PIN_AH14     
    sdram_addr[2] PIN_AG15     
    sdram_addr[3] PIN_AE14     
    sdram_addr[4] PIN_AB15     
    sdram_addr[5] PIN_AC14     
    sdram_addr[6] PIN_AD14     
    sdram_addr[7] PIN_AF15     
    sdram_addr[8] PIN_AH15     
    sdram_addr[9] PIN_AG13     
    sdram_addr[10] PIN_AG12    
    sdram_addr[11] PIN_AH13    
    sdram_addr[12] PIN_AJ14    
    sdram_ba[0] PIN_AF13 	     
    sdram_ba[1] PIN_AJ12 	     
    sdram_cas_n PIN_AF11 	     
    sdram_cke PIN_AK13 	     
    sdram_clk PIN_AH12 	     
    sdram_cs_n PIN_AG11 	     
    sdram_dq[0] PIN_AK6 	     
    sdram_dq[1] PIN_AJ7 	     
    sdram_dq[2] PIN_AK7 	     
    sdram_dq[3] PIN_AK8 	     
    sdram_dq[4] PIN_AK9 	     
    sdram_dq[5] PIN_AG10 	     
    sdram_dq[6] PIN_AK11 	     
    sdram_dq[7] PIN_AJ11 	     
    sdram_dq[8] PIN_AH10 	     
    sdram_dq[9] PIN_AJ10 	     
    sdram_dq[10] PIN_AJ9 	     
    sdram_dq[11] PIN_AH9 	     
    sdram_dq[12] PIN_AH8 	     
    sdram_dq[13] PIN_AH7 	     
    sdram_dq[14] PIN_AJ6 	     
    sdram_dq[15] PIN_AJ5 	     
    sdram_dqm[0] PIN_AB13 	     
    sdram_ras_n	 PIN_AE13 	     
    sdram_dqm[1] PIN_AK12 	     
    sdram_we_n   PIN_AA13 

    vga_out_r[0] PIN_A13 	     
    vga_out_r[1] PIN_C13 	     
    vga_out_r[2] PIN_E13 	     
    vga_out_r[3] PIN_B12 	     
    vga_out_r[4] PIN_C12 	     
    VGA_R[5] PIN_D12 	     
    VGA_R[6] PIN_E12 	     
    VGA_R[7] PIN_F13 	     

    vga_out_g[0] PIN_J9  	     
    vga_out_g[1] PIN_J10 	     
    vga_out_g[2] PIN_H12 	     
    vga_out_g[3] PIN_G10 	     
    vga_out_g[4] PIN_G11 	     
    vga_out_g[5] PIN_G12 	     
    VGA_G[6] PIN_F11 	     
    VGA_G[7] PIN_E11 	     

    vga_out_b[0] PIN_B13 	     
    vga_out_b[1] PIN_G13 	     
    vga_out_b[2] PIN_H13 	     
    vga_out_b[3] PIN_F14 	     
    vga_out_b[4] PIN_H14 	     
    VGA_B[5] PIN_F15 	     
    VGA_B[6] PIN_G15 	     
    VGA_B[7] PIN_J14 
    
    clk_vga PIN_A11 	     
    vga_out_hs PIN_B11 	     
    vga_out_vs PIN_D11 
    VGA_BLANK_N PIN_F10 
    VGA_SYNC_N PIN_C10 

} {
    set_location_assignment $pin -to $port
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to $port
}

set sdcFilename "${moduleName}.sdc"

set_global_assignment -name SDC_FILE $sdcFilename

set sdcf [open $sdcFilename "w"]
puts $sdcf {
    create_clock -period 20 [get_ports clk]

    derive_pll_clocks -create_base_clocks
    derive_clock_uncertainty
}
close $sdcf

project_close
