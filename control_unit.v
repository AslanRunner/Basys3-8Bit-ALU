`timescale 1ns / 1ps 

module control_unit(
    input [15:0] inputs,

    output reg [3:0] opcode,
    output reg [3:0] R_a_addr,
    output reg [3:0] R_b_addr, 
    output reg [3:0] R_d_addr,

    output reg [7:0] ram_addr,
    output reg [7:0] w 
);


always @(*) begin
    R_a_addr = 4'b0000;
    R_b_addr = 4'b0000;
    R_d_addr = 4'b0000;

    ram_addr = 8'b00000000;
    w = 8'b00000000;

    opcode = inputs[15:12]; 
    case(opcode)
        // 4'b0000 (LOA):
        4'b0000: begin
            R_d_addr = inputs[11:8];
            w = inputs[7:0];
        end

        // 4'b0001 (REA)
        4'b0001: begin
            R_d_addr = inputs[11:8];
            ram_addr = inputs[7:0];
        end

        // 4'b0010 (STR)
        4'b0010: begin
            R_a_addr = inputs[11:8];
            ram_addr = inputs[7:0];
        end

        // 4'b0011 (MOV)
        4'b0011: begin
            R_a_addr = inputs[11:8];
            R_d_addr = inputs[7:4];
        end

        // 4'b0100 (ADD)
        4'b0100: begin
            R_a_addr = inputs[11:8];
            R_b_addr = inputs[7:4];
            R_d_addr = inputs[3:0];
        end

        // 4'b0101(SUB)
        4'b0101: begin
            R_a_addr = inputs[11:8];
            R_b_addr = inputs[7:4];
            R_d_addr = inputs[3:0];
        end
        // 4'b0110 (INC)
        4'b0110: begin
            R_a_addr = inputs[11:8];
            R_d_addr = inputs[7:4];
        end
        // 4'b0111 (DEC)
         4'b0111: begin
            R_a_addr = inputs[11:8];
            R_d_addr = inputs[7:4];
        end

        //4'b1000(AND)
        4'b1000: begin
            R_a_addr = inputs[11:8];
            R_b_addr = inputs[7:4];
            R_d_addr = inputs[3:0];
        end

        //4'b1001(ORX):
        4'b1001:begin
            R_a_addr = inputs[11:8];
            R_b_addr = inputs[7:4];
            R_d_addr = inputs[3:0];
        end

        //4'b1010 (XOR)
        4'b1010:begin
            R_a_addr = inputs[11:8];
            R_b_addr = inputs[7:4];
            R_d_addr = inputs[3:0];
        end

        //4'b1011 (NOT)
        4'b1011: begin
            R_a_addr = inputs[11:8];
            R_d_addr = inputs[7:4];
        end

        //4'b1100 (SHL)
        4'b1100: begin
            R_a_addr = inputs[11:8];
            R_d_addr = inputs[7:4];
        end

        // 4'b1101 (SHR)
        4'b1101: begin
            R_a_addr = inputs[11:8];
            R_d_addr = inputs[7:4];
        end

            // 4'b1110 (CMP)
        4'b1110: begin
            R_a_addr = inputs[11:8];
            R_b_addr = inputs[7:4];
        end

            // 4'b1111 (NEX)
        4'b1111: begin
            // bos
        end

        default: begin
            opcode = 4'b1111;
        end
    endcase
end

endmodule
 

