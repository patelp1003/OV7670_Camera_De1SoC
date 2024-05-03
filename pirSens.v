module pirSens(
	input wire pirTest,
	output reg ledPIR
	);

	always @* begin
		if (pirTest) begin
			ledPIR = 1;
		end		
		else begin
			ledPIR = 0;
		end
	end
endmodule
