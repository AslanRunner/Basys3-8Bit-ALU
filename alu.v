`timescale 1ns / 1ps 


module alu(
    input clk,
    input trigger,
    
    input [3:0] R_a_addr, 
    input [3:0] R_b_addr,
    input [3:0] R_d_addr, 
    input [7:0] ram_addr, 
    input [3:0] opcode, 
    input [7:0] w,
    
    output reg [7:0] out_data, 
    output reg sign_bit,

    output reg flag_B,  // Ra > Rb : 1
    output reg flag_E,  // Ra = Rb : 1
    output reg flag_K    // Ra < Rb : 1
);


reg [7:0] RAM [0:255] ;
reg [7:0] R [0:15] ;
reg trigger_prev;
// BASLANGİC DURUMU

initial begin
    out_data = 8'b00000000;
    flag_B = 0;
    flag_E = 0;
    flag_K = 0;
end

// İSLEMLER
always @(posedge clk) begin

    sign <= out_data[7];

    trigger_prev <= trigger;
    if(trigger && !trigger_prev) begin
        case (opcode)
        4'b0000: begin // LOA
                R[R_d_addr] <= w ;
                out_data <= w ;
            end
    
        4'b0001: begin // REA
                R[R_d_addr] <= RAM[mem_addr] ;
                out_data <= RAM[mem_addr] ;
            end
    
        4'b0010: begin // STR
                RAM[mem_addr] <= R[R_a_addr] ;
                out_data <= R[R_a_addr] ;  // veri dogrulama
            end
    
        4'b0011: begin // MOV
                R[R_d_addr] <= R[R_a_addr] ;
                out_data <= R[R_a_addr] ;
            end
    
        4'b0100: begin // ADD
                R[R_d_addr] <= R[R_a_addr] + R[R_b_addr] ;
                out_data <= R[R_a_addr] + R[R_b_addr] ;
            end
    
        4'b0101: begin // SUB
                R[R_d_addr] <= R[R_a_addr] - R[R_b_addr] ;
                out_data <= R[R_a_addr] - R[R_b_addr] ;
            end
    
        4'b0110: begin // INC
                R[R_d_addr] <= R[R_a_addr] + 1 ;
                out_data <= R[R_a_addr] + 1 ;
            end
        
        4'b0111: begin // DEC
                R[R_d_addr] <= R[R_a_addr] - 1 ;
                out_data <= R[R_a_addr] - 1 ;
            end
    
        4'b1000: begin // AND
                R[R_d_addr] <= R[R_a_addr] & R[R_b_addr] ;
                out_data <= R[R_a_addr] & R[R_b_addr] ;
            end
    
        4'b1001: begin // ORX
                R[R_d_addr] <= R[R_a_addr] | R[R_b_addr] ;
                out_data <= R[R_a_addr] | R[R_b_addr] ;
            end
        
        4'b1010: begin // XOR
                R[R_d_addr] <= R[R_a_addr] ^ R[R_b_addr] ;
                out_data <= R[R_a_addr] ^ R[R_b_addr] ;
            end
    
        4'b1011: begin // NOT
                R[R_d_addr] <= ~R[R_a_addr] ;
                out_data <= ~R[R_a_addr] ;
            end
    
        4'b1100: begin // SHL 2 katina cikar
                R[R_d_addr] <= R[R_a_addr] << 1 ;
                out_data <= R[R_a_addr] << 1 ;
            end
    
        4'b1101: begin // SHR yariya indir
                R[R_d_addr] <= R[R_a_addr] >> 1 ;
                out_data <= R[R_a_addr] >> 1 ;
            end
    
        4'b1110: begin // CMP karsilastir
                if ($signed(R[R_a_addr]) > $signed(R[R_b_addr])) begin
                    flag_B <= 1'b1 ; flag_E <= 1'b0 ; flag_K <= 1'b0 ; 
                end else if ($signed(R[R_a_addr]) == $signed(R[R_b_addr])) begin
                    flag_B <= 1'b0 ; flag_E <= 1'b1 ; flag_K <= 1'b0 ;
                end else begin
                    flag_B <= 1'b0 ; flag_E <= 1'b0 ; flag_K <= 1'b1 ;
                end
            end
               
        4'b1111: begin // NEX
                // Hicbir sey yapma (No-Operation)
            end
     endcase
end
end
endmodule
