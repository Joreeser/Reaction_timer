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
    logic [3:0] time_delay, delay, sseg_ctrl, sseg_def, thou, hun, tens, ones;
    logic [12:0] count_ms, count_s;
    logic [27:0] seed = 28'b1110110001111110011101101100;
    logic tick_s, tick_ms, go;
    
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
     
            // sseg display "HI"
            value[13:7] = 4'hf;
            value[6:0] = 4'h1;
            value[27:14] = 8'h00;
            sseg_ctrl = 4'b0000;
                
            if (start)
                next_state = START0;
            else
                next_state = state;
            end
            
            START0:
            begin
            // Blank display on sseg
            sseg_ctrl = 4'b1111;
            
            //Delay value has to be at least 2
            //if (delay < 2)
                //time_delay = 2;
            //else 
                //time_delay = delay;
                
            // Count up seconds due to output of rand_delay mod_m_counter    
            //if (tick_s)
                //count_s = count_s + 1; 
                
            if (stop)
                next_state = ERROR1;
            else if (count_s == delay)
                next_state = START1;
            else
                next_state = state;  
            end
            
            START1:
            begin
            led = 1;
            go = 1; 
            
            //if (tick_ms)
                //count_ms = count_ms + 1;
            
            value [27:0] = {thou, hun, tens, ones}; // Display count on sseg
            sseg_ctrl = 4'b0000;
            
            if (value == 28'h1000)
                next_state = ERROR2;
            else if (stop)
                next_state = ERROR2;
            else 
                next_state = state;   
            end
          
            STOP:
            begin
            // Display count
            value = value;
            sseg_ctrl = 4'b0000;
            
            if (reset)
                next_state = READY;
            else
                next_state = state;
            end
            
            ERROR1:
            begin
            // Display "9999" on sseg
            value = 28'h9999;
            sseg_ctrl = 4'b0000;
            
            if (reset)
                next_state = READY;
            else
                next_state = state;
            end
            
            ERROR2:
            begin
            // Display "1000" on sseg
            value = 28'h1000;
            sseg_ctrl = 4'b0000;
            
            if (reset)
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
    //stop_watch_cascade stopwatch(.clk(clk), .go(go), .clr(reset), .d2(d2), .d1(d1), .d0(d0));
    counter s_count(.clk(clk), .tick(tick_s), .reset(reset), .count(count_s));
    counter ms_count(.clk(clk), .tick(tick_ms), .reset(reset), .count(count_ms));
    BCD_13bit ms_binary_to_dec(.in(count_ms), .thousands(thou), .hundreds(hun), .tens(tens), .ones(ones));
     
    hex_to_sseg sseg_for_disp0(.hex(value[6:0]), .dp(1), .sseg(display[6:0]));
    hex_to_sseg sseg_for_disp1(.hex(value[13:7]), .dp(1), .sseg(display[13:7]));
    hex_to_sseg sseg_for_disp2(.hex(value[20:14]), .dp(1), .sseg(display[20:14]));
    hex_to_sseg sseg_for_disp3(.hex(value[27:21]), .dp(1), .sseg(display[27:21]));
    disp_mux sseg_control(.clk(clk), .reset(reset), .in3(display[27:21]), .in2(display[20:14]), .in1(display[13:7]), .in0(display[6:0]), .an(sseg_def), .sseg(sseg));
   
endmodule
