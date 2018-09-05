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
    output logic [3:0] an,
    output logic [7:0] sseg
    );
    
    logic [27:0] display, value;
    logic [3:0] delay, count_s;
    logic count_ms;
    logic [27:0] seed = 28'b1110110001111110011101101100;
    logic tick_s, tick_ms;
    
    // Set up state variables for program states
    typedef enum {READY, START0, START1, STOP, ERROR1, ERROR2} TimerStates;
    TimerStates state, next_state;
    
    // Flip flop to move between states
    always_ff @(posedge clk, posedge reset)
        if (reset)
            state = READY;
        else
            state = next_state;
    
    
    // State logic
    always_comb
    begin
        case (state)
            READY:
            begin
            led = 1; // LED active low
            count_s = 0;
            count_ms = 0;
                
            // sseg display "HI"
            display[27:14] = 0;
            display[13:7] = 7'b0001001;
            display[6:0] = 7'b1111001;
                
            if (start)
                next_state = START0;
            else
                next_state = READY;
            end
            
            START0:
            begin
            // Delay value has to be at least 2
            if (delay < 2)
                delay = 2;
                
            // Count up seconds due to output of rand_delay mod_m_counter    
            if (tick_s)
                ++count_s; 
                    
            // Blank display on sseg
            an = 4'b1111;
                
            if (count_s == delay)
                begin
                next_state = START1;
                count_ms = 0;
                end
            else if (stop)
                next_state = ERROR1;
            else
                next_state = START0;  
            end
            
            START1:
            begin
            led = 0; // Turn on LED (active low)
            
            if (tick_ms)
                ++count_ms;
            
            value = count_ms; // Display count on sseg
            
            if (stop)
                next_state = STOP;
            else if (count_ms == 1000)
                next_state = ERROR2;
            else 
                next_state = START1;   
            end
          
            STOP:
            begin
            // Display count
            value = count_ms;
            
            if (reset)
                next_state = READY;
            else
                next_state = STOP;
            end
            
            ERROR1:
            begin
            // Display "9999" on sseg
            value = 28'h9999;
            
            if (reset)
                next_state = READY;
            else
                next_state = ERROR1;
            end
            
            ERROR2:
            begin
            // Display "1000" on sseg
            value = 28'h1000;
            
            if (reset)
                next_state = READY;
            else
                next_state = ERROR2;
            end
        endcase
    end

    LFSR_fib168pi rand_gen0(.clk(clk), .reset(reset), .seed(seed), .r(delay[0]));
    LFSR_fib168pi rand_gen1(.clk(clk), .reset(reset), .seed(seed), .r(delay[1]));
    LFSR_fib168pi rand_gen2(.clk(clk), .reset(reset), .seed(seed), .r(delay[2]));
    LFSR_fib168pi rand_gen3(.clk(clk), .reset(reset), .seed(seed), .r(delay[3]));     
    mod_m_counter #(.M(100000000)) rand_delay(.clk(clk), .reset(reset), .max_tick(tick_s), .q());
    mod_m_counter #(.M(100000)) react_time(.clk(clk), .reset(reset), .max_tick(tick_ms), .q()); 
    hex_to_sseg sseg_for_disp0(.hex(value[6:0]), .dp(1), .sseg(display[6:0]));
    hex_to_sseg sseg_for_disp1(.hex(value[13:7]), .dp(1), .sseg(display[13:7]));
    hex_to_sseg sseg_for_disp2(.hex(value[20:14]), .dp(1), .sseg(display[20:14]));
    hex_to_sseg sseg_for_disp3(.hex(value[27:21]), .dp(1), .sseg(display[27:21]));
    disp_mux sseg_control(.clk(clk), .reset(reset), .in3(display[27:21]), .in2(display[20:14]), .in1(display[13:7]), .in0(display[6:0]), .an(an), .sseg(sseg));
    
    
endmodule
