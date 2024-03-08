`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/19 21:56:00
// Design Name: 
// Module Name: PC
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


module PC(
    input           clk,
    input           rst,
    input           start,
    input [31:0]    jump_addr,
    input           jump_sel,   //jump or +4
    input           flush,      //output NOP instead of new Inst
    output      [31:0]  instruction,
    output reg  [31:0]  pc_addr,
    //inst ram bus
    input [31:0]    inst_ram_waddr,     //13b useful
    input           inst_ram_wen,
    input [31:0]    inst_ram_wdata
    );
    
localparam      EBREAK  = 32'h00100076;

wire    [31:0]  inst_ram_out;
wire            halt;
reg             halt_d1, halt_d2;
reg             load;   //load instruction
reg             flush_d1;

always@(posedge clk) begin
    flush_d1    <= flush;
    halt_d1     <= (inst_ram_out == EBREAK);
    halt_d2     <= halt_d1;
end

always@(posedge clk) begin
    if(rst) load    <= 0;
    else if(start)  load    <= 1;
    else if(halt)   load    <= 0;
end

always@(posedge clk) begin
    if(rst) begin
        pc_addr     <= 0;
    end else begin
        if(load) begin
            if(halt) begin
                pc_addr     <= 32'h800;
            end else if(jump_sel) begin
                pc_addr     <= jump_addr;
            end else begin
                pc_addr     <= pc_addr + 4;
            end
        end else begin
            pc_addr     <= pc_addr;
        end
    end
end
    
inst_blkmem     inst_blkmem_dut(
    .clka   (clk),
    .addra  (inst_ram_waddr),
    .wea    (inst_ram_wen),
    .dina   (inst_ram_wdata),
    .clkb   (clk),
    .addrb  (pc_addr[31:2]),
    .doutb  (inst_ram_out)
);

assign  halt        = halt_d2;
assign  instruction = (halt|flush_d1)?0:inst_ram_out;
    
endmodule
