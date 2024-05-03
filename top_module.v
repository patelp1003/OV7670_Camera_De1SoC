`timescale 1ns / 1ps

   module top_module(
	input wire clk,rst_n,
	input wire[3:0] key, //key[1:0] for brightness control , key[3:2] for contrast control
	//input wire pir,
	//input wire pirTest,
	//input wire btn,
    output wire [9:3] LEDR,
        //camera pinouts
	input wire cmos_pclk,cmos_href,cmos_vsync,
	input wire[7:0] cmos_db,
	inout cmos_sda,cmos_scl, 
	output wire cmos_rst_n, cmos_pwdn, cmos_xclk,
	//Debugging
	output wire led0_r, led0_g, led0_b, led0_test, led0_start,
	//controller to sdram
	output wire sdram_clk, cmos_pwr, cmos_gnd,
	output wire sdram_cke, 
	output wire sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n, 
	output wire[12:0] sdram_addr,
	output wire[1:0] sdram_ba, 
	output wire[1:0] sdram_dqm, 
	inout[15:0] sdram_dq,
	//VGA output
	
   output wire clk_vga, 
	output wire[7:0] vga_out_r,
	output wire[7:0] vga_out_g,
	output wire[7:0] vga_out_b,
	output wire vga_out_vs,vga_out_hs
    
        //sd card 
    /*input wire SD_MISO,
	output wire SD_MOSI,
	output wire SD_DCLK,SD_nCS,*/
	
	//UART for debuggingdin
	//output wire uart_rx,uart_tx
        //
        // output idle,
        //HOST interface
        //input write, //start writing to SD card
        //output reg rd_fifo, //read next data to be written
        //input[7:0] data //data to be written to SD catd
  
    );
	 
	 wire f2s_data_valid;
	 wire[9:0] data_count_r;
	 wire[15:0] dout, dout_SD;
	 wire[15:0] din;
	 wire clk_sdram;
	 wire empty_fifo;
	 //wire clk_vga;
	 wire state;
	 wire rd_en;
     wire empty, rd_en_cam;
	 //wire idle;
	 
	 reg [27:0] c;

    always @(posedge clk) begin
    if(!rst_n)
    c <= 0;
    
    else begin
    if(c[27])begin   
    
    led0_test <=0;
    led0_r<=0;
    led0_g<=0;
    led0_b<=0;
    end
    
    else begin
    led0_test <=1;
    led0_r<=1;
    led0_g<=1;
    led0_b<=1;
    end
    
    c <= c+1;
    end
        
    end


         //module instantiations
    //sdcard_interface m5
    //(
        //.clk(clk_sdram),
        //.rst(!rst_n),
        //.led0_r(led0_r),
        //.led0_g(led0_g),
        //.led0_b(led0_b), //{red,green,blue} red if SDCARD initialization is stuck at CMD0, blue if stuck somewhere else, green if initialization complete
        //.idle(idle),  //sdcard not bdinusy
         //HOST interface
        //.write({!empty}),
        //.rd_fifo(rd_en_cam),
        //.data(dout_SD[7:0]),
        //SPI pinouts
        //.SD_MISO(SD_MISO),
        //.SD_MOSI(SD_MOSI),
        //.SD_DCLK(SD_DCLK),
        //.SD_nCS(SD_nCS),
        //UART for debugging
        //.uart_rx(uart_rx),
        //.uart_tx(uart_tx)
    //);
    wire pir;
    assign pir = 0;
    assign cmos_pwr = 1;
    assign cmos_gnd = 0;
    
	camera_interface m0 //control logic for retrieving data from camera, storing data to asyn_fifo, and  sending data to sdram
	(
		.clk(clk),
		.clk_100(clk_sdram),
		.rst_n(rst_n),
		.key(key),
        .empty(empty),
		.pir(pir),
		.start_camera(idle),
		//asyn_fifo IO/homes/user/stud/spring24/pp2870/Downloads/SecureCam/Test/top_module.qsf 
		.rd_en(f2s_data_valid),
		.rd_en_SD(rd_en_cam),
		.data_count_r(data_count_r),
		.dout(dout),
		.dout_SD(dout_SD),
		//camera pinouts
		.cmos_pclk(cmos_pclk),
		.cmos_href(cmos_href),
		.cmos_vsync(cmos_vsync),
		.cmos_db(cmos_db),
		.cmos_sda(cmos_sda),
		.cmos_scl(cmos_scl), 
		.cmos_rst_n(cmos_rst_n),
		.cmos_pwdn(cmos_pwdn),
		.cmos_xclk(cmos_xclk),
		//Debugging
		.led_start(led0_start)
    );
	 
	 sdram_interface m1 //control logic for writing the pixel-data from camera to sdram and reading pixel-data from sdram to vga
	 (
		.clk(clk_sdram),
		.rst_n(rst_n),
		//asyn_fifo IO
		.clk_vga(clk_vga),
		.rd_en(rd_en),
		.data_count_r(data_count_r),
		.f2s_data(dout),
		.f2s_data_valid(f2s_data_valid),
		.empty_fifo(empty_fifo),
		.dout(din),
		//controller to sdram
		.sdram_cke(sdram_cke), 
		.sdram_cs_n(sdram_cs_n),
		.sdram_ras_n(sdram_ras_n),
		.sdram_cas_n(sdram_cas_n),
		.sdram_we_n(sdram_we_n), 
		.sdram_addr(sdram_addr),
		.sdram_ba(sdram_ba), 
		.sdram_dqm(sdram_dqm),
		.sdram_dq(sdram_dq)
    );
	 
	 vga_interface m2 //control logic for retrieving data from sdram, storing data to asyn_fifo, and sending data to vga
	 (
		.clk(clk),
		.rst_n(rst_n),
		//asyn_fifo IO
		.empty_fifo(empty_fifo),
		.din(din),
		.clk_vga(clk_vga),
		.rd_en(rd_en),   

		//VGA output
		.vga_out_r(vga_out_r),
		.vga_out_g(vga_out_g),
		.vga_out_b(vga_out_b),
		.vga_out_vs(vga_out_vs),
		.vga_out_hs(vga_out_hs)
    );

    two_edge	two_edge_inst_a (
	.datain_h (1'b1),
	.datain_l (1'b0),
	.outclock (clk_sdram),
	.dataout (sdram_clk)
	);

     clock_143_0002 clock_143_inst (
		.refclk   (clk),   //  refclk.clk
		.rst      (rst),      //   reset.reset WHERE DOES RESET SIGNAL COME FROM?
		.outclk_0 (clk_sdram), // outclk0.clk
		.locked   ()          // (terminated)
	);
	
	/*pirSens m3 (
		.pirTest(pirTest),
		.ledPIR(LEDR[3])
	);*/

endmodule
