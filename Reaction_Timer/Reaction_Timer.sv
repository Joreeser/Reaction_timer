///////////////////////////////////////////////////////
// Author: Jordan Reeser
//
// Create Date: 09/03/2018 01:29:53 PM
// Module Name: Reaction_Timer
//
// Description: Module to instantiate a reaction timer
//
///////////////////////////////////////////////////////


module Reaction_Timer(
    input logic start, stop, reset, clk,
    output logic led,
    output logic [7:0] an,
    output logic [7:0] sseg
    );
    
    logic [15:0] value;
    logic [31:0] display;
    logic [3:0] delay, thou, hun, tens, ones, new_delay;
    logic [12:0] count_ms, count_s;
    logic [27:0] seed = 28'b1110110001111110011101101100;
    logic tick_s, tick_ms, clr_ms, clr_s, hold, start_s;
    
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
            led = 0; // Initialize off (active high)
            clr_s = 1; // Hold count at 0
            clr_ms = 1; 
            hold = 0;
            new_delay = 6;
     
            // sseg display "HI"
            value[7:4] = 4'hf; // f has been changed to display "h"
            value[3:0] = 4'h1;
            value[15:8] = 8'hee; // e has been changed to blank display
           
           // Next state logic     
            if (start)
            begin
                next_state = START0;
                start_s = 1;
            end   
            else
                next_state = state;
            end
            
            START0:
            begin
            clr_s = 0; // Allow counter to start
            hold = 0;
            
            // Blank display on sseg
            value = 16'heeee;
            
            if (start_s)
                begin
                new_delay = delay;
                start_s = 0;
                end
            else 
                new_delay = new_delay;
            
            //Delay value has to be at least 2
            if (new_delay < 2)
                new_delay = new_delay | 4'b0010;

            // Next state logic    
            if (stop)
                next_state = ERROR1;
            else if (count_s == {9'b0, new_delay})
                next_state = START1;
            else
                next_state = state;  
            end
            
            START1:
            begin
            led = 1; // Turn on LED
            clr_ms = 0; // Start reaction counter
            clr_s = 1; // Clear delay counter
            hold = 0;

            value [15:0] = {thou, hun, tens, ones}; // Display count on sseg
            
            // Next state logic
            if (count_ms == 1000)
                next_state = ERROR2;
            else if (stop)
                begin
                next_state = STOP;
                hold = 1; // Hold count value 
                end
            else 
                next_state = state;   
            end
          
            STOP:
            begin
            // Display count
            hold = 1;
            
            // Next state logic
            if (reset)
                next_state = READY;
            else
                next_state = state;
            end
            
            ERROR1:
            begin
            // Display "9999" on sseg
            value = 16'h9999;
            
            // Next state logic
            if (reset)
                next_state = READY;
            else
                next_state = state;
            end
            
            ERROR2:
            begin
            // Display "1000" on sseg
            value = 16'h1000;
            
            // Next state logic
            if (reset)
                next_state = READY;
            else
                next_state = state;
            end
        endcase
    end
    
    // Turn off second set of sseg
    assign an[7:4] = 4'b1111;

    LFSR_fib168pi rand_gen(.clk(clk), .reset(reset), .seed(seed), .r(delay)); // Generate rand number for delay 
    mod_m_counter #(.M(100000000)) rand_delay(.clk(clk), .reset(reset), .max_tick(tick_s), .q()); // Counter for tick every second
    mod_m_counter #(.M(100000)) react_time(.clk(clk), .reset(reset), .max_tick(tick_ms), .q()); // Counter for tick every ms
    counter#(.SIZE(13)) s_count(.clk(clk), .tick(tick_s), .reset(reset | clr_s), .stop(), .count(count_s)); // Second counter
    counter#(.SIZE(13)) ms_count(.clk(clk), .tick(tick_ms), .reset(reset | clr_ms), .stop(hold), .count(count_ms)); // Ms counter
    BCD_13bit ms_binary_to_dec(.in(count_ms), .thousands(thou), .hundreds(hun), .tens(tens), .ones(ones)); // BCD converter
    hex_to_sseg sseg_for_disp0(.hex(value[3:0]), .dp(1), .sseg(display[7:0])); // Convert binary to sseg sontrol values
    hex_to_sseg sseg_for_disp1(.hex(value[7:4]), .dp(1), .sseg(display[15:8]));
    hex_to_sseg sseg_for_disp2(.hex(value[11:8]), .dp(1), .sseg(display[23:16]));
    hex_to_sseg sseg_for_disp3(.hex(value[15:12]), .dp(1), .sseg(display[31:24]));
    disp_mux sseg_control(.clk(clk), .reset(reset), .in3(display[31:24]), .in2(display[23:16]), .in1(display[15:8]), .in0(display[7:0]), .an(an[3:0]), .sseg(sseg)); // Display on sseg
   
endmodule
