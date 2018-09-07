`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2017 06:33:27 PM
// Design Name: 
// Module Name: BCD_overflow
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


module add3
   (input [3:0] in,
    output [3:0] out);
      
    assign out = (in >= 5) ? in+3 : in;
    
endmodule
