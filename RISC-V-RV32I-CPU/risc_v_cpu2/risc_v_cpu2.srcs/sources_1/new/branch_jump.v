`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/01 00:14:59
// Design Name: 
// Module Name: branch_jump
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


module branch_jump(
    input               rst,
    input   [31:0]      jump_cmp_data1,
    input   [31:0]      jump_cmp_data2,
    input   [31:0]      imm_data,
    input   [31:0]      pc_addr,
    input   [6:0]       opcode,
    input   [2:0]       funccode,
    output  reg [31:0]      jump_addr,
    output  reg [31:0]      jump_sel,
    output                  flush
);
    
wire    [31:0]          jump_cmp_res;
assign  jump_cmp_res     = jump_cmp_data1 - jump_cmp_data2;    
    
always@(*) begin
    if(rst) begin
        jump_sel    <= 0;
    end else begin
        if(opcode == 7'b1101111 || opcode == 7'b1100111) begin   //JAL, JALR
            jump_sel   <= 1;
        end else if(opcode == 7'b1100011) begin
            case(funccode)
                3'b000: jump_sel    <= (jump_cmp_data1 == jump_cmp_data2); //beq
                3'b001: jump_sel    <= (jump_cmp_data1 != jump_cmp_data2); //bne
                3'b100: jump_sel    <= jump_cmp_res[31]; //blt
                3'b101: jump_sel    <= ~jump_cmp_res[31]; //bge
                3'b110: jump_sel    <= (jump_cmp_data1 < jump_cmp_data2); //bltu
                3'b111: jump_sel    <= (jump_cmp_data1 >= jump_cmp_data2); //bgeu
                default: jump_sel   <= 0;
            endcase
        end else begin
            jump_sel   <= 0;
        end
    end
end

assign  flush   = jump_sel;

always@(*) begin
    if(rst) begin
        jump_addr   <= 0;
    end else begin
        if(opcode == 7'b1101111 || opcode == 7'b1100011) begin   //JAL, beq...
            jump_addr   <= pc_addr + imm_data;
        end else if(opcode == 7'b1100111) begin //JALR
            jump_addr   <= jump_cmp_data1 + imm_data;
        end else begin
            jump_addr   <= jump_addr;
        end
    end
end
    
endmodule
