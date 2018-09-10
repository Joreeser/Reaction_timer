module counter#(
	parameter SIZE = 13)(
	input logic clk, reset, tick, stop,
	output logic [SIZE-1:0] count);

	always_ff @(posedge clk, posedge reset)
		if (reset)
			count = 0;
		else if (stop)
            count = count;
		else if (tick)
			count = count + 1;
		

endmodule
