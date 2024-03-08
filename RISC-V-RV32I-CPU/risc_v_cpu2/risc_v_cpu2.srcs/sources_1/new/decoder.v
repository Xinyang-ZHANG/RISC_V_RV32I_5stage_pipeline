`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/20 22:33:17
// Design Name: 
// Module Name: decoder
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


module decoder(
    input           clk,
    input           rst,
    input  [31:0]       instruction,
    output reg [ 4:0]   r1_addr,
    output reg [ 4:0]   r2_addr,
    output reg [31:0]   imm_data,
    output reg [ 4:0]   rd_addr,
    output reg          subsra,
    output reg [ 2:0]   funccode,
    output reg [ 6:0]   opcode,
    input               flush
    );
    
reg     [19:0]  imm_data_h;     //JAL后紧跟ADDI会造成高位错误，因此用该信号缓存高位
   
always@(posedge clk) begin
    if(rst) begin
        r1_addr     <= 0;
        r2_addr     <= 0;
        imm_data    <= 0;
        imm_data_h  <= 0;
        rd_addr     <= 0;
        subsra      <= 0;
        funccode    <= 0;
        opcode      <= 0;
    end else begin
        if(flush) begin
            r1_addr     <= 0;
            r2_addr     <= 0;
            imm_data    <= 0;
            imm_data_h  <= imm_data_h;
            rd_addr     <= 0;
            subsra      <= 0;
            funccode    <= 0;
            opcode      <= 0;
        end else begin
            opcode      <= instruction[6:0];
            case(instruction[6:0])
                7'b0010011, 7'b1100111, 7'b0000011: begin   //I //立即数操作 //无条件跳转指令JALR //载入指令
                    r1_addr     <= instruction[19:15];
                    r2_addr     <= 0;
                    imm_data    <= instruction[31]?({imm_data_h,12'h000} - (~instruction[31:20]+1)):({imm_data_h,12'h000} + instruction[31:20]);
                    imm_data_h  <= imm_data_h;
                    rd_addr     <= instruction[11:7];
                    subsra      <= 0;
                    funccode    <= instruction[14:12];
                end
                7'b0110011: begin   //R //寄存器运算操作
                    r1_addr     <= instruction[19:15];
                    r2_addr     <= instruction[24:20];
                    imm_data    <= imm_data;
                    imm_data_h  <= imm_data_h;   
                    rd_addr     <= instruction[11:7];
                    subsra      <= instruction[30];
                    funccode    <= instruction[14:12];
                end
                7'b0110111, 7'b0010111: begin   //U //立即数载入LUI, AUIPC
                    r1_addr     <= 0;
                    r2_addr     <= 0;
                    imm_data    <= {instruction[31:12],12'h000};
                    imm_data_h  <= instruction[31:12];
                    rd_addr     <= instruction[11:7];
                    subsra      <= 0;
                    funccode    <= instruction[14:12];
                end
                7'b1101111: begin   //J //无条件跳转指令JAL，不看imm_data_h
                    r1_addr     <= 0;
                    r2_addr     <= 0;
                    imm_data    <= instruction[31]?{11'hfff,instruction[31],instruction[19:12],instruction[20],instruction[30:21],1'b0}
                                                  :{11'h000,instruction[31],instruction[19:12],instruction[20],instruction[30:21],1'b0};
                    imm_data_h  <= imm_data_h;   
                    rd_addr     <= instruction[11:7];
                    subsra      <= 0;
                    funccode    <= 0; 
                end
                7'b1100011: begin   //B //条件跳转指令，不看imm_data_h
                    r1_addr     <= instruction[19:15];
                    r2_addr     <= instruction[24:20];
                    imm_data    <= instruction[31]?{19'hfffff,instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0}
                                                  :{19'h00000,instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
                    imm_data_h  <= imm_data_h;   
                    rd_addr     <= 0;
                    subsra      <= 0;
                    funccode    <= instruction[14:12];
                end
                7'b0100011: begin   //S //存储指令
                    r1_addr     <= instruction[19:15];
                    r2_addr     <= instruction[24:20];
                    imm_data    <= instruction[31]?({imm_data_h,12'h000} - (~{instruction[31:25],instruction[11:7]}+1))
                                                  :({imm_data_h,12'h000} + {instruction[31:25],instruction[11:7]});
                    imm_data_h  <= imm_data_h;                              
                    rd_addr     <= 0;
                    subsra      <= 0;
                    funccode    <= instruction[14:12];
                end
                default: begin      //I //NOP
                    r1_addr     <= 0;
                    r2_addr     <= 0;
                    imm_data    <= 0;
                    imm_data_h  <= imm_data_h;   
                    rd_addr     <= 0;
                    subsra      <= 0;
                    funccode    <= 0;
                end
            endcase
        end
    end
end
    
endmodule
