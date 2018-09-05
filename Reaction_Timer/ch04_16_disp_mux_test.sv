// Listing 4.16
`timescale 1ns / 1ps

module disp_mux_test;
 
    logic clk = 0;
    logic [3:0] btn;
    logic [7:0] sw;
    logic [3:0] an;
    logic [7:0] sseg;

   // signal declaration
   logic [7:0] d3_reg, d2_reg, d1_reg, d0_reg;

   // instantiate 7-seg LED display time-multiplexing module
   disp_mux disp_unit
      (.clk(clk), .reset(1'b0), .in0(d0_reg), .in1(d1_reg),
       .in2(d2_reg), .in3(d3_reg), .an(an), .sseg(sseg));

always
    #10 clk=!clk;

   // registers for 4 led patterns
   always_ff @(posedge clk)
   begin
      if (btn[3])
         d3_reg <= sw;
      if (btn[2])
         d2_reg <= sw;
      if (btn[1])
         d1_reg <= sw;
      if (btn[0])
         d0_reg <= sw;
    end
    
    initial
    begin
        btn = 4'b0000; #15;
        btn = 4'b0001; #15;
        btn = 4'b0010; #15;
        btn = 4'b0011; #15;
        btn = 4'b0100; #15;
        btn = 4'b0101; #15;
        btn = 4'b1000; #15;
    end
endmodule