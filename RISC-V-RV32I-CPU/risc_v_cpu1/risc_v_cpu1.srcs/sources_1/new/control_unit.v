`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/24 15:54:12
// Design Name: 
// Module Name: control_unit
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


module control_unit(
    input           clk,
    input           rst,
    input [6:0]     opcode,
    input [2:0]     funccode,
    input [31:0]    jump_cmp_data1,
    input [31:0]    jump_cmp_data2,
    output reg      jump_sel,
    output reg      dmem_wren,
    output reg      wb_sel
    );
    
reg                     wb_sel_d3;
wire    [31:0]          jump_cmp_res;
assign  jump_cmp_res     = jump_cmp_data1 - jump_cmp_data2;    
    
always@(posedge clk) begin
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

always@(posedge clk) begin
    if(rst) begin
        dmem_wren   <= 0;
    end else begin
        dmem_wren   <= (opcode == 7'b0100011);  //sw
    end
end

always@(posedge clk) begin
    if(rst) begin
        wb_sel_d3   <= 0;
        wb_sel      <= 0;
    end else begin
        wb_sel_d3   <= (opcode == 7'b0000011);  //lw
        wb_sel      <= wb_sel_d3;
    end
end
    
endmodule
