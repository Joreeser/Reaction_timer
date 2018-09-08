`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2017 06:01:01 PM
// Design Name: 
// Module Name: BCD_13bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module BCD_13bit
   (input logic [12:0] in,
    output logic [3:0] thousands, hundreds, tens, ones);
    
    logic [3:0] c1_w, c2_w, c3_w;
    logic [7:0] c4_w, c5_w, c6_w;
    logic [11:0] c7_w, c8_w, c9_w;
   
    add3 C1(.in({1'b0, in[12:10]}), .out(c1_w));
    add3 C2(.in({c1_w[2:0], in[9]}), .out(c2_w));
    add3 C3(.in({c2_w[2:0], in[8]}), .out(c3_w));
    
    add3 C4[1:0](.in({1'b0, c1_w[3], c2_w[3], c3_w, in[7]}), .out(c4_w));
    add3 C5[1:0](.in({c4_w[6:0], in[6]}), .out(c5_w));
    add3 C6[1:0](.in({c5_w[6:0], in[5]}), .out(c6_w));
    
    add3 C7[2:0](.in({1'b0, c4_w[7], c5_w[7], c6_w, in[4]}), .out(c7_w));
    add3 C8[2:0](.in({c7_w[10:0], in[3]}), .out(c8_w));
    add3 C9[2:0](.in({c8_w[10:0], in[2]}), .out(c9_w));
    add3 C10[2:0](.in({c9_w[10:0], in[1]}), .out({thousands[0], hundreds[3:0], tens[3:0], ones[3:1]}));
    
    assign thousands[3:1] = {c7_w[11], c8_w[11], c9_w[11]};
    assign ones[0] = in[0];
    
endmodule
