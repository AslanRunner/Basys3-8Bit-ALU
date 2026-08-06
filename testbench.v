`timescale 1ns / 1ps 

module testbench(
    input clk,          
    input btnC,        
    input [15:0] sw,    
    output [3:0] an,    
    output [6:0] seg,   
    output dp           
);

    assign dp = 1'b1; 

    // Debouncer logic
    // debouncer resource : https://www.youtube.com/watch?v=2dgFvj3WwXk&t=1998s
    reg btnC_sync_0;
    reg btnC_sync_1;
    reg btnC_clean;
    reg [19:0] debounce_counter;

    initial begin
        btnC_sync_0 = 1'b0;
        btnC_sync_1 = 1'b0;
        btnC_clean = 1'b0;
        debounce_counter = 20'b0;
    end

    always @(posedge clk) begin
        btnC_sync_0 <= btnC;
        btnC_sync_1 <= btnC_sync_0;

        if (btnC_sync_1 == btnC_clean) begin
            debounce_counter <= 0;
        end else begin
            debounce_counter <= debounce_counter + 1;
            if (debounce_counter == 20'hFFFFF) begin 
                btnC_clean <= btnC_sync_1;
                debounce_counter <= 0;
            end
        end
    end


    wire [3:0] op; 
    wire [3:0] rd, ra, rb; 
    wire [7:0] addr, w_t, alu_out;  
    wire sign;
  

    // add Control Unit to system
    control_unit cu_inst (
        .inputs(sw),  
        .opcode(op), 
        .R_d_addr(rd), 
        .R_a_addr(ra), 
        .R_b_addr(rb),  
        .ram_addr(addr),  
        .w(w_t) 
    );

    //  add ALU to system
    alu my_alu (
        .clk(clk),
        .trigger(btnC_clean),
        .opcode(op),  
        .R_d_addr(rd),  
        .R_a_addr(ra), 
        .R_b_addr(rb), 
        .ram_addr(addr),  
        .w(w_t), 
        .sign(sign), 
        .out_data(alu_out)
    );

    // Find the absolute value of the negative number (Take its inverse + add 1)
    wire [7:0] abs_val = sign ? (~alu_out + 1'b1) : alu_out;

    // Binary to BCD
    reg [3:0] yuzler, onlar, birler; 
    always @(*) begin 
        yuzler = abs_val / 100; 
        onlar  = (abs_val % 100) / 10; 
        birler = abs_val % 10; 
    end 


    // There's a refresh counter trick for displays.
    // Resource : https://www.fpga4student.com/2017/09/seven-segment-led-display-controller-basys3-fpga.html
    reg [19:0] refresh_counter = 0; 
    always @(posedge clk) begin 
        refresh_counter <= refresh_counter + 1; 
    end 
    
    wire [1:0] led_activating_counter = refresh_counter[19:18]; 
    reg [3:0] active_digit; 
    reg [3:0] an_temp;  
    
    always @(*) begin 
        case(led_activating_counter) 
            2'b00: begin 
                an_temp = 4'b1110; 
                active_digit = birler; 
            end 
            2'b01: begin 
                an_temp = 4'b1101; 
                active_digit = onlar; 
            end 
            2'b10: begin 
                an_temp = 4'b1011; 
                active_digit = yuzler;
            end 
            2'b11: begin 
                an_temp = 4'b0111; 
                active_digit = sign ? 4'b1010 : 4'b1111;  
            end 
        endcase
    end 
    
    assign an = an_temp; 
    reg [6:0] seg_temp; 
    
    // 7 Segment LED display
    always @(*) begin 
        case(active_digit) 
            4'b0000: seg_temp = 7'b1000000; // 0
            4'b0001: seg_temp = 7'b1111001; // 1
            4'b0010: seg_temp = 7'b0100100; // 2
            4'b0011: seg_temp = 7'b0110000; // 3
            4'b0100: seg_temp = 7'b0011001; // 4
            4'b0101: seg_temp = 7'b0010010; // 5
            4'b0110: seg_temp = 7'b0000010; // 6
            4'b0111: seg_temp = 7'b1111000; // 7
            4'b1000: seg_temp = 7'b0000000; // 8
            4'b1001: seg_temp = 7'b0010000; // 9
            4'b1010: seg_temp = 7'b0111111; // "-"
            4'b1111: seg_temp = 7'b1111111; // empty
            default: seg_temp = 7'b1111111; // empty
        endcase 
    end
    
    assign seg = seg_temp; 

endmodule 
