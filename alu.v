`timescale 1ns / 1ps

module alu(
    input clk, 
    input trigger, 
    
    // register adress
    input [3:0] R_a_addr, 
    input [3:0] R_b_addr,
    input [3:0] R_d_addr, 

    input [7:0] ram_addr, 
    input [3:0] opcode, // operation code
    input [7:0] w,
    
    output reg [7:0] out_data, 
    output reg sign // "-" 
);


reg [7:0] RAM [0:255] ;
reg [7:0] R [0:15] ;
reg trigger_prev; 

wire [7:0] add_result = R[R_a_addr] + R[R_b_addr];
wire [7:0] sub_result = R[R_a_addr] - R[R_b_addr];
wire [7:0] inc_result = R[R_a_addr] + 1;
wire [7:0] dec_result = R[R_a_addr] - 1;
wire [7:0] and_result = R[R_a_addr] & R[R_b_addr];
wire [7:0] or_result  = R[R_a_addr] | R[R_b_addr];
wire [7:0] xor_result = R[R_a_addr] ^ R[R_b_addr];
wire [7:0] not_result = ~R[R_a_addr];
wire [7:0] shl_result = R[R_a_addr] << 1;
wire [7:0] shr_result = R[R_a_addr] >> 1;

initial begin
    out_data = 8'b00000000;
end


// ALU 
always @(posedge clk) begin

    trigger_prev <= trigger;
    if(trigger && !trigger_prev) begin
        case (opcode)
        4'b0000: begin // LOA
                R[R_d_addr] <= w ;
                out_data <= w ;
                sign <= w[7]; 
            end
    
        4'b0001: begin // REA
                R[R_d_addr] <= RAM[ram_addr] ;
                out_data <= RAM[ram_addr] ;
                sign <= RAM[ram_addr][7];
            end
    
        4'b0010: begin // STR
                RAM[ram_addr] <= R[R_a_addr] ;
                out_data <= R[R_a_addr] ; 
                sign <= R[R_a_addr][7];
            end
    
        4'b0011: begin // MOV
                R[R_d_addr] <= R[R_a_addr] ;
                out_data <= R[R_a_addr] ;
                sign <= R[R_a_addr][7];
            end
    
        4'b0100: begin // ADD
                R[R_d_addr] <= R[R_a_addr] + R[R_b_addr] ;
                out_data <= R[R_a_addr] + R[R_b_addr] ;
                sign <= add_result[7];
            end
    
        4'b0101: begin // SUB
                R[R_d_addr] <= R[R_a_addr] - R[R_b_addr] ;
                out_data <= R[R_a_addr] - R[R_b_addr] ;
                sign <= sub_result[7];
            end
    
        4'b0110: begin // INC
                R[R_d_addr] <= R[R_a_addr] + 1 ;
                out_data <= R[R_a_addr] + 1 ;
                sign <= inc_result[7];
            end
        
        4'b0111: begin // DEC
                R[R_d_addr] <= R[R_a_addr] - 1 ;
                out_data <= R[R_a_addr] - 1 ;
                sign <= dec_result[7]; 
            end
    
        4'b1000: begin // AND
                R[R_d_addr] <= R[R_a_addr] & R[R_b_addr] ;
                out_data <= R[R_a_addr] & R[R_b_addr] ;
                sign <= and_result[7];
            end
    
        4'b1001: begin // ORX
                R[R_d_addr] <= R[R_a_addr] | R[R_b_addr] ;
                out_data <= R[R_a_addr] | R[R_b_addr] ;
                sign <= or_result[7];
            end
        
        4'b1010: begin // XOR
                R[R_d_addr] <= R[R_a_addr] ^ R[R_b_addr] ;
                out_data <= R[R_a_addr] ^ R[R_b_addr] ;
                sign <= xor_result[7];
            end
    
        4'b1011: begin // NOT
                R[R_d_addr] <= ~R[R_a_addr] ;
                out_data <= ~R[R_a_addr] ;
                sign <= not_result[7];
            end
    
        4'b1100: begin // SHL 
                R[R_d_addr] <= R[R_a_addr] << 1 ;
                out_data <= R[R_a_addr] << 1 ;
                sign <= shl_result[7];
            end
    
        4'b1101: begin // SHR 
                R[R_d_addr] <= R[R_a_addr] >> 1 ;
                out_data <= R[R_a_addr] >> 1 ;
                sign <= 1'b0;
            end
    
      4'b1110: begin // CMP 
                sign <= 1'b0; 
                out_data <= R[R_a_addr]; 
                
                if (R[R_a_addr] > R[R_b_addr]) begin
                    out_data <= 8'b01100100;
                end else if (R[R_a_addr] == R[R_b_addr]) begin
                    out_data <= 8'b00001010;
                end else begin
                    out_data <= 8'b00000001;
                end
            end
               
        4'b1111: begin // NEX
            end
     endcase
end
end
endmodule
