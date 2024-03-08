`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/19 22:57:44
// Design Name: 
// Module Name: data_path
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


module data_path(
    input           clk,
    input           rst,
    input           start,
    input           jump_sel,
    input           dmem_wren,
    output [31:0]   instruction,
    input  [ 4:0]   r1_addr,
    input  [ 4:0]   r2_addr,
    input  [31:0]   imm_data,
    input  [ 4:0]   rd_addr,
    input           subsra,
    input  [ 2:0]   funccode,
    input  [ 6:0]   opcode,
    output [31:0]   jump_cmp_data1,
    output [31:0]   jump_cmp_data2,
    input           wb_sel,
    output          flush,
    //inst ram bus
    input [31:0]    inst_ram_waddr,     //13b useful
    input           inst_ram_wen,
    input [31:0]    inst_ram_wdata,
    //data ram bus
    input [31:0]    data_ram_waddr,     //13b useful
    input           data_ram_wen,
    input [31:0]    data_ram_wdata
    );

wire        [31:0]  r1_data, r2_data, rd_data;    
wire        [31:0]  pc_addr, jump_addr, dmem_addr;
reg         [31:0]  pc_addr_d1, pc_addr_d2;
reg         [31:0]  rd_data_d4;
reg         [ 4:0]  rd_addr_d3, rd_addr_d4;
reg         [ 2:0]  funccode_d3, funccode_d4;
wire        [31:0]  dmem_dout;
reg         [31:0]  rd_data_wb;


always@(posedge clk) begin
    pc_addr_d1  <= pc_addr;
    pc_addr_d2  <= pc_addr_d1;
    if(flush | rst | start)
        rd_addr_d3  <= 0;
    else
        rd_addr_d3  <= rd_addr;
    rd_addr_d4      <= rd_addr_d3;
    rd_data_d4      <= rd_data;
    funccode_d3     <= funccode;
    funccode_d4     <= funccode_d3;
end

//d1
PC      PC_dut(
    .clk            (clk),
    .rst            (rst),
    .start          (start),
    .jump_addr      (jump_addr),
    .jump_sel       (jump_sel),   //jump or +4
    .flush          (flush),      //output NOP instead of new Inst
    .instruction    (instruction),
    .pc_addr        (pc_addr),
    //inst ram bus
    .inst_ram_waddr (inst_ram_waddr),     //13b useful
    .inst_ram_wen   (inst_ram_wen),
    .inst_ram_wdata (inst_ram_wdata)
);

//d2
regfile     regfile_dut(
    .clk            (clk),
    .rst            (rst),
    .r1_addr        (r1_addr),
    .r2_addr        (r2_addr),
    .r1_data        (r1_data),
    .r2_data        (r2_data),
    .rd_wren        (1),
    .rd_addr        (rd_addr_d4),
    .rd_data        (rd_data_wb)
);

assign  jump_cmp_data1 = r1_data;
assign  jump_cmp_data2 = r2_data;

//d3
ALU     ALU_dut(
    .clk            (clk),
    .rst            (rst|start),
    .r1_data        (r1_data),
    .r2_data        (r2_data),
    .imm_data       (imm_data),
    .pc_addr        (pc_addr_d2),
    .rd_data        (rd_data),
    .dmem_addr      (dmem_addr),
    .jump_addr      (jump_addr),
    .subsra         (subsra),
    .funccode       (funccode),
    .opcode         (opcode),
    .flush          (flush)
);

//d4
data_blkmem     data_blkmem_dut(
    .clka   (clk),
    .addra  (data_ram_wen?data_ram_waddr:dmem_addr[31:2]),
    .wea    (data_ram_wen?1:dmem_wren),
    .dina   (data_ram_wen?data_ram_wdata:rd_data),
    .douta  (dmem_dout)
);
//d4 mux
always@(*) begin
    if(wb_sel) begin
        case(funccode_d4)
            3'b000: rd_data_wb  = dmem_dout[7]?{24'hffffff,dmem_dout[7:0]}:{24'h000000,dmem_dout[7:0]};
            3'b100: rd_data_wb  = {24'h000000,dmem_dout[7:0]};
            3'b001: rd_data_wb  = dmem_dout[15]?{16'hffff,dmem_dout[15:0]}:{16'h0000,dmem_dout[15:0]};
            3'b101: rd_data_wb  = {16'h0000,dmem_dout[15:0]};
            3'b010: rd_data_wb  = dmem_dout;
            default:    rd_data_wb  = dmem_dout;
        endcase
    end else begin
        rd_data_wb  = rd_data_d4;
    end
end
    
endmodule
