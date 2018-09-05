`timescale 1ns / 1ps

module lfsr_fib168_tf;

logic clk=0, reset=0;
logic [27:0] seed;
logic r;

LFSR_fib168pi DUT(
 .clk(clk),
  .reset(reset),
  .seed(seed),
  .r(r)
);

always
    #5 clk=!clk;

initial
begin
seed<=28'b11101100011111100111011011001;
#1 reset<=1;
#1 reset<=0;
end

endmodule
