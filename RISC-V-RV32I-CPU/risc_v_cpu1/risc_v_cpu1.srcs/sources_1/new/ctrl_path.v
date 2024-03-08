`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/19 23:14:58
// Design Name: 
// Module Name: ctrl_path
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


module ctrl_path(
    input           clk,
    input           rst,
    input           start,
    output          jump_sel,
    input  [31:0]   instruction,
    output [ 4:0]   r1_addr,
    output [ 4:0]   r2_addr,
    output [31:0]   imm_data,
    output [ 4:0]   rd_addr,
    output          subsra,
    output [ 2:0]   funccode,
    output [ 6:0]   opcode,
    input [31:0]    jump_cmp_data1,
    input [31:0]    jump_cmp_data2,
    output          dmem_wren,
    output          wb_sel,
    input           flush,
    //gen load
    input           inst_ram_wen,
    input           data_ram_wen
    );
    

//d2
decoder     decoder_dut(
    .clk            (clk),
    .rst            (rst|start),
    .instruction    (instruction),
    .r1_addr        (r1_addr),
    .r2_addr        (r2_addr),
    .imm_data       (imm_data),
    .rd_addr        (rd_addr),
    .subsra         (subsra),
    .funccode       (funccode),
    .opcode         (opcode),
    .flush          (flush)
);

//d3
control_unit    control_unit_dut(
    .clk            (clk),
    .rst            (rst|start),
    .opcode         (opcode),
    .funccode       (funccode),
    .jump_cmp_data1 (jump_cmp_data1),
    .jump_cmp_data2 (jump_cmp_data2),
    .jump_sel       (jump_sel),
    .dmem_wren      (dmem_wren),
    .wb_sel         (wb_sel)
);
    
endmodule
