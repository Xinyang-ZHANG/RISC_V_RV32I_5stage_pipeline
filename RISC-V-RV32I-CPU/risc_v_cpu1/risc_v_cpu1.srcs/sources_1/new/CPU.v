`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/19 21:55:36
// Design Name: 
// Module Name: CPU
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


module CPU(
    input           clk,
    input           rst,
    input           start,
    //inst ram bus
    input [31:0]    inst_ram_waddr,     //13b useful
    input           inst_ram_wen,
    input [31:0]    inst_ram_wdata,
    //data ram bus
    input [31:0]    data_ram_waddr,     //13b useful
    input           data_ram_wen,
    input [31:0]    data_ram_wdata
    );
    
    wire            jump_sel;
    wire [31:0]     instruction;
    wire [ 4:0]     r1_addr;
    wire [ 4:0]     r2_addr;
    wire [31:0]     imm_data;
    wire [ 4:0]     rd_addr;
    wire            subsra;
    wire [ 2:0]     funccode;
    wire [ 6:0]     opcode;
    wire [31:0]    jump_cmp_data1;
    wire [31:0]    jump_cmp_data2;
    wire            dmem_wren;
    wire            wb_sel;
    wire            flush;
    
ctrl_path       ctrl_path_dut(
    .clk            (clk),
    .rst            (rst),
    .start          (start),
    .jump_sel       (jump_sel),
    .instruction    (instruction),
    .r1_addr        (r1_addr),
    .r2_addr        (r2_addr),
    .imm_data       (imm_data),
    .rd_addr        (rd_addr),
    .subsra         (subsra),
    .funccode       (funccode),
    .opcode         (opcode),
    .jump_cmp_data1 (jump_cmp_data1),
    .jump_cmp_data2 (jump_cmp_data2),
    .dmem_wren      (dmem_wren),
    .wb_sel         (wb_sel),
    .flush          (flush),
    //gen load
    .inst_ram_wen   (inst_ram_wen),
    .data_ram_wen   (data_ram_wen)
);

data_path       data_path_dut(
    .clk            (clk),
    .rst            (rst),
    .start          (start),
    .jump_sel       (jump_sel),
    .instruction    (instruction),
    .r1_addr        (r1_addr),
    .r2_addr        (r2_addr),
    .imm_data       (imm_data),
    .rd_addr        (rd_addr),
    .subsra         (subsra),
    .funccode       (funccode),
    .opcode         (opcode),
    .jump_cmp_data1 (jump_cmp_data1),
    .jump_cmp_data2 (jump_cmp_data2),
    .dmem_wren      (dmem_wren),
    .wb_sel         (wb_sel),
    .flush          (flush),
    //inst ram bus
    .inst_ram_waddr (inst_ram_waddr),     //13b useful
    .inst_ram_wen   (inst_ram_wen),
    .inst_ram_wdata (inst_ram_wdata),
    //data ram bus
    .data_ram_waddr (data_ram_waddr),     //13b useful
    .data_ram_wen   (data_ram_wen),
    .data_ram_wdata (data_ram_wdata)
);
    
endmodule
