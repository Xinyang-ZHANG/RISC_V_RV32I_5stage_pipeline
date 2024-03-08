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
    output reg      dmem_wren,
    output reg      wb_sel
    );
    
reg                     wb_sel_d3;

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
