/*
 * Avalon memory-mapped peripheral controlling OV7670 to BRAM
 *
 * Stephen A. Edwards
 * Columbia University
 */

module vga_ball(input logic        clk,
	    input logic 	    reset,
		input logic [7:0]   writedata,
		input logic 	    write,
		input 		        chipselect,
		input logic [2:0]   address,
		output logic [7:0]  readdata,
		input logic 	    read,

		//////////////////////////////////////
		input wire  [3:0]   VGA_KEY,
		
		/////////////////LEDS//////////////////
		output wire [9:0]   VGA_LEDR,
		//output wire       led0_r, led0_g, led0_b, led0_test, led0_start,
		/////////////////CAMERA//////////////////
		input wire          VGA_CMOS_PCLK,VGA_CMOS_HREF,VGA_CMOS_VSYNC,
	    input wire  [7:0]   VGA_CMOS_DB,
	    inout               VGA_CMOS_SDA,VGA_CMOS_SCL,
	    
		output wire         VGA_CMOS_RST_N, VGA_CMOS_PWDN, VGA_CMOS_XCLK,
		output wire         VGA_CMOS_PWR, VGA_CMOS_GND,
		
	    /////////////////VGA//////////////////
	    output logic [7:0]  VGA_R, VGA_G, VGA_B,
		output logic 	    VGA_CLK, VGA_HS, VGA_VS
	//	                    VGA_BLANK_n,
	//	output logic 	    VGA_SYNC_n
		/*output wire       clk_vga, 
	    output wire [7:0] vga_out_r,
	    output wire [7:0] vga_out_g,
        output wire [7:0] vga_out_b,
	    output wire       vga_out_vs,vga_out_hs*/
		
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
	     if (reset) begin
	        readdata <= 8'h0;
	      
         end else if (chipselect && read)
               case (address)
	         3'h0 : readdata <= 8'h2;
       endcase

	 end

     always @(posedge clk) begin
        if(reset)
         c <= 0;
    
        else begin
            if(c[27])begin   
    
                VGA_LEDR[3] <=0;
              // led0_r<=0;
              // led0_g<=0;
                VGA_LEDR[4]<=0;
            end
    
            else begin
             VGA_LEDR[3] <=1;
            // led0_r<=1;
            // led0_g<=1;
             VGA_LEDR[4]<=1;
            end
   
            c <= c+1;
       end
        
    end
    
    wire pir;
    assign pir = 0;
    assign VGA_CMOS_PWR = 1;
    assign VGA_CMOS_GND = 0;
    assign VGA_LEDR[8]=!(reset);
    
	camera_interface m0 //control logic for retrieving data from camera, storing data to asyn_fifo, and  sending data to sdram
	(
		.clk(clk),
		.clk_100(clk),
		.clk_vga(VGA_CLK),
		.rst_n(!reset),
		.key(VGA_KEY),
		.pir(pir),
		.rd_en_vga(rd_en),
		.rd_en(rd_en),
		.dout_vga(din),
		//camera pinouts
		.cmos_pclk(VGA_CMOS_PCLK),
		.cmos_href(VGA_CMOS_HREF),
		.cmos_vsync(VGA_CMOS_VSYNC),
		.cmos_db(VGA_CMOS_DB),
		.cmos_sda(VGA_CMOS_SDA),
		.cmos_scl(VGA_CMOS_SCL), 
		.cmos_rst_n(VGA_CMOS_RST_N),
		.cmos_pwdn(VGA_CMOS_PWDN),
		.cmos_xclk(VGA_CMOS_XCLK),
		//Debugging
		.led_start(VGA_LEDR[2]),
		.flag(VGA_LEDR[0]),
		.flag2(VGA_LEDR[1])
		
		
    );
   
    vga_interface m2 //control logic for retrieving data from sdram, storing data to asyn_fifo, and sending data to vga
    (
		.clk(clk),
		.rst_n(!reset),
		//asyn_fifo IO
		.empty_fifo(),
		.din(din),
		.clk_vga(VGA_CLK),
		.rd_en(rd_en),   

		//VGA output
		.vga_out_r(VGA_R),
		.vga_out_g(VGA_G),
		.vga_out_b(VGA_B),
		.vga_out_vs(VGA_VS),
		.vga_out_hs(VGA_HS)
    );
endmodule
