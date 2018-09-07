//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/03/2018 01:29:53 PM
// Design Name: 
// Module Name: Reaction_Timer
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


module Reaction_Timer(
    input logic start, stop, reset, clk,
    output logic led,
    output logic [7:0] an,
    output logic [7:0] sseg
    );
    
    logic [27:0] display, value;
    logic [3:0] time_delay, delay, count_s, sseg_ctrl, sseg_def;
    logic count_ms;
    logic [27:0] seed = 28'b1110110001111110011101101100;
    logic tick_s, tick_ms;
    
    // Set up state variables for program states
    typedef enum {READY, START0, START1, STOP, ERROR1, ERROR2} TimerStates;
    TimerStates state, next_state;
    
    // Flip flop to move between states
    always_ff @(posedge clk, posedge reset)
        if (reset)
            state <= READY;
        else
            state <= next_state;
    
    
    // State logic
    always_comb
    begin
        case (state)
            READY:
            begin
            led = 0; 
            count_s = 0;
            count_ms = 0;
                
            // sseg display "HI"
            value[27:21] = 4'hf;
            value[20:14] = 4'h1;
            value[13:0] = 8'h00;
            sseg_ctrl = 4'b0011;
                
            if (posedge start)
                next_state = START0;
            else
                next_state = state;
            end
            
            START0:
            begin
            // Delay value has to be at least 2
            //if (delay < 2)
                //time_delay = (delay | 4'b0001);
            //else 
                //time_delay = delay;
                
            // Count up seconds due to output of rand_delay mod_m_counter    
            if (tick_s)
                ++count_s; 
                    
            // Blank display on sseg
            sseg_ctrl = 4'b1111;
                
            if (count_s == delay)
                next_state = START1;
            else if (posedge stop)
                next_state = ERROR1;
            else
                next_state = state;  
            end
            
            START1:
            begin
            led = 1; 
            
            if (tick_ms)
                ++count_ms;
            
            value = count_ms; // Display count on sseg
            sseg_ctrl = 4'b0000;
            
            if (posedge stop)
                next_state = STOP;
            else if (count_ms == 1000)
                next_state = ERROR2;
            else 
                next_state = state;   
            end
          
            STOP:
            begin
            // Display count
            value = count_ms;
            sseg_ctrl = 4'b0000;
            
            if (posedge reset)
                next_state = READY;
            else
                next_state = state;
            end
            
            ERROR1:
            begin
            // Display "9999" on sseg
            value = 28'h9999;
            sseg_ctrl = 4'b0000;
            
            if (posedge reset)
                next_state = READY;
            else
                next_state = state;
            end
            
            ERROR2:
            begin
            // Display "1000" on sseg
            value = 28'h1000;
            sseg_ctrl = 4'b0000;
            
            if (posedge reset)
                next_state = READY;
            else
                next_state = state;
            end
        endcase
    end
    
    assign an[3:0] = (sseg_ctrl == 4'b0000) ? sseg_def : sseg_ctrl;
    assign an[7:4] = 4'b1111;

    LFSR_fib168pi rand_gen(.clk(clk), .reset(reset), .seed(seed), .r(delay));    
    mod_m_counter #(.M(100000000)) rand_delay(.clk(clk), .reset(reset), .max_tick(tick_s), .q());
    mod_m_counter #(.M(100000)) react_time(.clk(clk), .reset(reset), .max_tick(tick_ms), .q()); 
    hex_to_sseg sseg_for_disp0(.hex(value[6:0]), .dp(1), .sseg(display[6:0]));
    hex_to_sseg sseg_for_disp1(.hex(value[13:7]), .dp(1), .sseg(display[13:7]));
    hex_to_sseg sseg_for_disp2(.hex(value[20:14]), .dp(1), .sseg(display[20:14]));
    hex_to_sseg sseg_for_disp3(.hex(value[27:21]), .dp(1), .sseg(display[27:21]));
    disp_mux sseg_control(.clk(clk), .reset(reset), .in3(display[27:21]), .in2(display[20:14]), .in1(display[13:7]), .in0(display[6:0]), .an(sseg_def), .sseg(sseg));
   
endmodule
