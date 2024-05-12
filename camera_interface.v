`timescale 1ns / 1ps

  module camera_interface(
	input wire clk,clk_100,rst_n, clk_vga,
	input wire[3:0] key, //key[1:0] for brightness control , key[3:2] for contrast control
	input wire pir,
	//asyn_fifo IO
	input wire rd_en, rd_en_SD, rd_en_vga,
	output wire[9:0] data_count_r,
	output wire[15:0] dout,
	output wire[15:0] dout_SD,
	//camera pinouts
	input wire cmos_pclk,cmos_href,cmos_vsync,
	input wire[7:0] cmos_db,
	inout cmos_sda,cmos_scl, //i2c comm wires
	output wire cmos_rst_n, cmos_pwdn, cmos_xclk, empty, 

	//Debugging
	output led,
	output wire led_start, flag, flag2,
	/////////////////////////////////////////////////////
	output wire[7:0] dout_vga
    );
	 //FSM state declarations
	 localparam idle=0,
					start_sccb=1,
					write_address=2,
					write_data=3,
					digest_loop=4,
					delay=5,
					vsync_fedge=6,
					byte1=7,
					byte2=8,
					fifo_write=9,
					stopping=10;
					
	 localparam wait_init=0,
					sccb_idle=1,
					sccb_address=2,
					sccb_data=3,
					sccb_stop=4;

	localparam 			rest = 0,
					vsync_fedge_SD = 1,
					byte1_SD = 2,
					byte2_SD = 3;
					
					
	 localparam MSG_INDEX=78; //number of the last index to be digested by SCCB
	 
	 
	 
	 reg[3:0] state_q=0,state_d;
	 reg[2:0] sccb_state_q=0,sccb_state_d;
	 reg[7:0] addr_q,addr_d;
	 reg[7:0] data_q,data_d;
	 reg[7:0] brightness_q,brightness_d;
	 reg[7:0] contrast_q,contrast_d;
	 reg start,stop;
	 reg[7:0] wr_data;
	 wire rd_tick;
	 wire[1:0] ack;
	 wire[7:0] rd_data;
	 wire[3:0] state;
	 reg[3:0] led_q=0,led_d; 
	 reg[27:0] delay_q=0,delay_d;
	 reg start_delay_q=0,start_delay_d;
	 reg delay_finish;
	 reg[15:0] message[250:0];
	 reg[7:0] message_index_q=0,message_index_d;
	 reg[15:0] pixel_q,pixel_d;
	 reg wr_en, wr_en_SD;
	 reg mod2_q=0,mod2_d;
	 wire full;
	 wire key0_tick,key1_tick,key2_tick,key3_tick;
	 reg[2:0] lines_q,lines_d;
	 reg[18:0] count_q=0,count_d;

	 reg[3:0] state_q_SD=0, state_d_SD;
	 
	 //buffer for all inputs coming from the camera
	 reg pclk_1,pclk_2,href_1,href_2,vsync_1,vsync_2;

	 ////////////////////////////////////////////////
	reg[12:0] wr_ptr_q; //binary counter for write pointer
	wire[12:0] wr_ptr_d;
	reg[12:0] rd_ptr_q=0; //binary counter for read pointer
	wire[12:0] rd_ptr_d;
	wire  start_storing_d, delay_storing_d;
	reg  start_storing_q, delay_storing_q;
	wire state_42_d, line_counter_d, within_crop_image_d;
	reg  state_42_q, line_counter_q, within_crop_image_q;
	///////////////////////////////////////////////////
	initial begin //collection of all adddresses and values to be written in the camera
    
	message[0]=16'h12_80;  //reset all register to default values
	message[1]=16'h12_04;  //set output format to RGB
	message[2]=16'h15_00;  //pclk will not toggle during horizontal blank
	message[3]=16'h40_d0;	//RGB565
	 
	// These are values scalped from https://github.com/jonlwowski012/OV7670_NEXYS4_Verilog/blob/master/ov7670_registers_verilog.v
    message[4]= 16'h12_00; // COM7,     set RGB color output
    message[5]= 16'h11_60; // CLKRC     internal PLL matches input clock
    message[6]= 16'h0C_04; // COM3,     default settings
    message[7]= 16'h3E_1b; // COM14,    no scaling, normal pclock
    message[8]= 16'h04_00; // COM1,     disable CCIR656
    message[9]= 16'h40_c0; //COM15,     RGB565, full output range
    message[10]= 16'h3a_04; //TSLB       set correct output data sequence (magic)
	message[11]= 16'h14_6A; //COM9       MAX AGC value x4 0001_1000
    message[12]= 16'h42_B0; //MTX1       all of these are magical matrix coefficients
    message[13]= 16'h50_80; //MTX2write
    message[14]= 16'h51_00; //MTX3
    message[15]= 16'h52_22; //MTX4
    message[16]= 16'h53_5e; //MTX5
    message[17]= 16'h54_80; //MTX6
    message[18]= 16'h58_9E; //MTXS
    message[19]= 16'h3D_40; //COM13      sets gamma enable
	message[20]= 16'h17_14; //HSTART     start high 8 bits
    message[21]= 16'h18_02; //HSTOP      stop high 8 bits //these kill the odd colored line
    message[22]= 16'h32_80; //HREF       edge offset
    message[23]= 16'h19_03; //VSTART     start high 8 bits
    message[24]= 16'h1A_7B; //VSTOP      stop high 8 bits
    message[25]= 16'h03_0A; //VREF       vsync edge offset
    message[26]= 16'h0F_41; //COM6       reset timings
    message[27]= 16'h1E_20; //MVFP       disable mirror / flip //might have magic value of 03
    message[28]= 16'h33_0B; //CHLF       //magic value from the internet
    message[29]= 16'h3C_78; //COM12      no HREF when VSYNC low
    message[30]= 16'h69_00; //GFIX       fix gain control
    message[31]= 16'h74_00; //REG74      Digital gain control
    message[32]= 16'hB0_84; //RSVD       magic value from the internet *required* for good color
    message[33]= 16'hB1_0c; //ABLC1
    message[34]= 16'hB2_0e; //RSVD       more magic internet values
    message[35]= 16'hB3_80; //THL_ST
	message[36]= 16'h70_20;
    message[37]= 16'h71_20;
    message[38]= 16'h72_77;
    message[39]= 16'h73_03;
    message[40]= 16'ha2_01;
    //gamma curve values
    message[41]= 16'h7a_20;
    message[42]= 16'h7b_10;
    message[43]= 16'h7c_1e;
    message[44]= 16'h7d_35;
    message[45]= 16'h7e_5a;
    message[46]= 16'h7f_69;
    message[47]= 16'h80_76;
    message[48]= 16'h81_80;
    message[49]= 16'h82_88;
    message[50]= 16'h83_8f;
    message[51]= 16'h84_96;
    message[52]= 16'h85_a3;
    message[53]= 16'h86_af;
    message[54]= 16'h87_c4;
    message[55]= 16'h88_d7;
    message[56]= 16'h89_e8;
    //AGC and AEC
    message[57]= 16'h13_e0; //COM8, disable AGC / AEC
    message[58]= 16'h00_00; //set gain reg to 0 for AGC
    message[59]= 16'h10_00; //set ARCJ reg to 0
    message[60]= 16'h0d_40; //magic reserved bit for COM4
    message[61]= 16'h14_18; //COM9, 4x gain + magic bit
    message[62]= 16'ha5_05; // BD50MAX
    message[63]= 16'hab_07; //DB60MAX
    message[64]= 16'h24_95; //AGC upper limit
    message[65]= 16'h25_33; //AGC lower limit
    message[66]= 16'h26_e3; //AGC/AEC fast mode op region
    message[67]= 16'h9f_78; //HAECC1
    message[68]= 16'ha0_68; //HAECC2
    message[69]= 16'ha1_03; //magic
    message[70]= 16'ha6_d8; //HAECC3
    message[71]= 16'ha7_d8; //HAECC4
    message[72]= 16'ha8_f0; //HAECC5
    message[73]= 16'ha9_90; //HAECC6
    message[74]= 16'haa_94; //HAECC7
    message[75]= 16'h13_e5; //COM8, enable AGC / AEC
	message[76]= 16'h1E_23; //Mirror Image
	message[77]= 16'h69_06; //gain of RGB(manually adjusted)
	message[78]= 16'h6b_50; 
  end
	 
	 //register operations
	 always @(posedge clk_100,negedge rst_n) begin
		if(!rst_n) begin
			state_q<=0;
			state_q_SD<=0;
			led_q<=0;
			delay_q<=0;
			start_delay_q<=0;
			message_index_q<=0;
			pixel_q<=0;
			
			sccb_state_q<=0;
			addr_q<=0;
			data_q<=0;
			brightness_q<=0;
			contrast_q<=0;

			delay_storing_q<=0;
			start_storing_q<=0;

			line_counter_q<=1;
			state_42_q<=0;
		end
		else begin
			state_q<=state_d;
			state_q_SD<=state_d_SD;
			delay_q<=delay_d;
			start_delay_q<=start_delay_d;
			message_index_q<=message_index_d;			
			pclk_1<=cmos_pclk; 
			pclk_2<=pclk_1;
			href_1<=cmos_href;
			href_2<=href_1;
			vsync_1<=cmos_vsync;
			vsync_2<=vsync_1;
			pixel_q<=pixel_d;
			
			sccb_state_q<=sccb_state_d;
			addr_q<=addr_d;
			data_q<=data_d;
			brightness_q<=brightness_d;
			contrast_q<=contrast_d;

			delay_storing_q<=delay_storing_d;
			start_storing_q<=start_storing_d;

			line_counter_q<=line_counter_d;
			state_42_q<=state_42_d;
		end
	 end
	 	 
	 
	 //FSM next-state logics
	 always @* begin
		state_d=state_q;
		led_d=led_q;
		start=0;
		stop=0;
		wr_data=0;
		start_delay_d=start_delay_q;
		delay_d=delay_q;
		delay_finish=0;
		message_index_d=message_index_q;
		pixel_d=pixel_q;
		wr_en=0;
		
		sccb_state_d=sccb_state_q;
		addr_d=addr_q;
		data_d=data_q;
		brightness_d=brightness_q;
		contrast_d=contrast_q;
		

		//delay logic  
		if(start_delay_q) delay_d=delay_q+1'b1;
		if(delay_q[16] && message_index_q!=(MSG_INDEX+1) && (state_q!=start_sccb))  begin  //delay between SCCB transmissions (0.66ms)
			delay_finish=1;
			start_delay_d=0;
			delay_d=0;
		end
		else if((delay_q[26] && message_index_q==(MSG_INDEX+1)) || (delay_q[26] && state_q==start_sccb)) begin //delay BEFORE SCCB transmission, AFTER SCCB transmission, and BEFORE retrieving pixel data from camera (0.67s)
			delay_finish=1;
			start_delay_d=0;
			delay_d=0;
		end
	    if (!pir) begin
		case(state_q) 
		
					////////Begin: Setting register values of the camera via SCCB///////////
					
			  idle:  if(delay_finish) begin //idle for 0.6s to start-up the camera
							state_d=start_sccb; 
							start_delay_d=0;
							//led_start<=0;
						end
						else begin 
						start_delay_d=1;
						led_start<=1;
						end

		start_sccb:  begin   //start of SCCB transmission
							start=1;
							wr_data=8'h42; //slave address of OV7670 for write
							state_d=write_address;
												
						end
	 write_address: if(ack==2'b11) begin 
							wr_data=message[message_index_q][15:8]; //write address
							state_d=write_data;
							led_start<=0;
						end
		 write_data: if(ack==2'b11) begin 
							wr_data=message[message_index_q][7:0]; //write data
							state_d=digest_loop;
						end
	  digest_loop: if(ack==2'b11) begin //stop sccb transmission
							stop=1;
							start_delay_d=1;
							message_index_d=message_index_q+1'b1;
							state_d=delay;
						end
			  delay: begin
							if(message_index_q==(MSG_INDEX+1) && delay_finish) begin 
								state_d=vsync_fedge; //if all messages are already digested, proceed to retrieving camera pixel data
								led_d=4'b0110;
								led_start<=0;	
							end
							else if(state==0 && delay_finish) state_d=start_sccb; //small delay before next SCCB transmission(if all messages are not yet digested)
						end
			  
			  

				///////////////Begin: Retrieving Pixel Data from Camera to be Stored to SDRAM/////////////////
				
		vsync_fedge: if(vsync_1==0 && vsync_2==1) state_d=byte1; //vsync falling edge means new frame is incoming
				byte1: if(pclk_1==1 && pclk_2==0 && href_1==1 && href_2==1) begin //rising edge of pclk means new pixel data(first byte of 16-bit pixel RGB565) is available at output
								pixel_d[15:8]=cmos_db;

								state_d=byte2;
						 end
						 else if(vsync_1==1 && vsync_2==1) begin
							state_d=vsync_fedge;
						 end
				byte2: if(pclk_1==1 && pclk_2==0 && href_1==1 && href_2==1) begin //rising edge of pclk means new pixel data(second byte of 16-bit pixel RGB565) is available at output
								pixel_d[7:0]=cmos_db;
								state_d=fifo_write;
						 end
						 else if(vsync_1==1 && vsync_2==1) begin
							state_d=vsync_fedge;
						 end
		 fifo_write: begin //write the 16-bit data to asynchronous fifo to be retrieved later by SDRAM
								wr_en=1;
								state_d=byte1;
								if(full) led_d=4'b1001; //debugging led
								// wr_ptr_d = wr_ptr_q+1'b1;
						 end
		default: state_d=idle;
		endcase
		
		//Logic for increasing/decreasing brightness and contrast via the 4 keybuttons
		end

		
    end
	 

	 assign cmos_pwdn=0; 
	 assign cmos_rst_n=1;
	 assign led=led_q;
	 
	 //module instantiations
	 i2c_top #(.freq(100_000)) m0
	(
		.clk(clk_100),
		.rst_n(rst_n),
		.start(start),
		.stop(stop),
		.wr_data(wr_data),
		.rd_tick(rd_tick), //ticks when read data from servant is ready,data will be taken from rd_data
		.ack(ack), //ack[1] ticks at the ack bit[9th bit],ack[0] asserts when ack bit is ACK,else NACK
		.rd_data(rd_data), 
		.scl(cmos_scl),
		.sda(cmos_sda),
		.state(state)
    ); 

    clock_12_0002 clock_12_inst (
		.refclk   (clk),   //  refclk.clk
		.rst      (rst),      //   reset.reset
		.outclk_0 (cmos_xclk), // outclk0.clk
		.locked   ()          // (terminated)
	);

	debounce_explicit m4
	(
		.clk(clk_100),
		.rst_n(rst_n),
		.sw({!key[0]}),
		.db_level(),
		.db_tick(key0_tick)
    );
	///////////////////////////////////////////////////////////////////////////////////
	always @(posedge clk_vga, negedge rst_n)begin
		if(!rst_n) begin
			rd_ptr_q<=0;
		end
		else begin
			rd_ptr_q<=rd_ptr_d;
		end
	end

	always @(posedge clk_100, negedge rst_n)begin
		if(!rst_n) begin
			wr_ptr_q<=0;
		end
		else begin
			wr_ptr_q<=wr_ptr_d;
		end
	end

	always@*begin
		wr_ptr_d = wr_ptr_q;
		rd_ptr_d = rd_ptr_q;
		if(wr_en)begin
			if(wr_ptr_q>=4799)begin
				wr_ptr_d=0;
			end
			else
				wr_ptr_d=wr_ptr_q+1;
		end

		if(rd_en_vga)begin
			if(rd_ptr_q>=4799)
				rd_ptr_d=0;
			else
				rd_ptr_d=rd_ptr_q+1;
		end
	end
	
	always@* begin
		delay_storing_d=delay_storing_q;
		start_storing_d=start_storing_q;
		if(key0_tick)
			delay_storing_d=1;
		// else
		// 	delay_storing_d=0;
	
		if(delay_storing_q && wr_ptr_d == 0)begin
			start_storing_d=1;
			delay_storing_d=0;
		end
		
		if(start_storing_q && wr_ptr_d == 4799)
			start_storing_d=0;
	end
	assign flag2=start_storing_d; 
	
	localparam counting_till_42=0,
			   hit_42_and_waiting=1;

	always@*begin
		state_42_d=state_42_q;
		line_counter_d=line_counter_q;

		if((wr_ptr_d >= ((line_counter_q)*42)) && (wr_ptr_d <= ((line_counter_q)*42)+42) && wr_ptr_d<=3322)begin
			state_42_d=1;
		end
		else if((wr_ptr_d > ((line_counter_q)+42)) && (wr_ptr_d < ((line_counter_q)*42)+38) && wr_ptr_d<=3322)begin
			state_42_d=0;
		end

		if((wr_ptr_d == ((line_counter_q)*42)+38) && wr_ptr_d<=3322)begin
			line_counter_d = line_counter_q+1;
		end

		if(wr_ptr_d>3322)begin
			state_42_d=0;
		end

		if(wr_en)begin
			if(wr_ptr_q>=4799)begin
				line_counter_d=0;
				state_42_d=0;
			end
		end
	end

	dual_port_sync_mod d0(
		.clk_r(clk_vga),
		.clk_w(clk),
		.we(wr_en),
		.rd(rd_en_vga),
		.din(pixel_q[15:8]),
		.addr_a(wr_ptr_d),
		.addr_b(rd_ptr_d),
		.dout(dout_vga),
		.flag(flag),
		.start(start_storing_d),
		.state_42(state_42_d)
	);
	
endmodule


module dual_port_sync_mod
	#(
		parameter ADDR_WIDTH=13, //2k by 8 dual port synchronous ram(16k block ram)
					 DATA_WIDTH=8
	)
	(
		input clk_r,
		input clk_w,
		input we, rd, start, state_42,
		input[DATA_WIDTH-1:0] din,
		input[ADDR_WIDTH-1:0] addr_a,addr_b, //addr_a for write, addr_b for read
		output[DATA_WIDTH-1:0] dout,
		output wire flag
	);
	
	reg[DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];
	reg[ADDR_WIDTH-1:0] addr_b_q;
	reg full;
	assign full = (addr_a>=4799)?1:full;

	always @(posedge clk_w) begin
		if(we&&start&&state_42) begin ram[addr_a]<=din;flag = 1;end
		if(we&&start&&!state_42) begin ram[addr_a]<=8'b0000_0000;flag = 1;end
		else flag = 0;
		
		if(addr_b==0) ;
		
	end
	always @(posedge clk_r) begin
		addr_b_q<=addr_b;	
	end
	assign dout = (full)?ram[addr_b_q]:8'b0000_0000;
	
endmodule
