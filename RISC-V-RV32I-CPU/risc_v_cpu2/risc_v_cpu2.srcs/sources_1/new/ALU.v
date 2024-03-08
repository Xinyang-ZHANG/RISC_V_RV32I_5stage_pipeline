`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/22 23:16:47
// Design Name: 
// Module Name: ALU
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


module ALU(
    input           clk,
    input           rst,
    input  [31:0]   r1_data,
    input  [31:0]   r2_data,
    input  [31:0]   imm_data,
    input  [31:0]   pc_addr,
    output reg [31:0]   rd_data,
    output reg [31:0]   dmem_addr,
    input           subsra,
    input  [ 2:0]   funccode,
    input  [ 6:0]   opcode
);

wire    [31:0]      stli_res;
wire    [31:0]      stl_res;
assign  stli_res    = r1_data - imm_data;
assign  stl_res     = r1_data - r2_data;
    
always@(posedge clk) begin
    if(rst) begin
        rd_data     <= 0;
        dmem_addr   <= 0;
    end else begin
        case(opcode)
                7'b0010011: begin   //立即数操作 
                    dmem_addr   <= 0;
                    case(funccode)
                        3'b000: rd_data     <= (r1_data + imm_data);  //addi
                        3'b010: rd_data     <= stli_res[31];  //stli
                        3'b011: rd_data     <= (r1_data < imm_data);  //stliu
                        3'b111: rd_data     <= (r1_data & imm_data);  //andi
                        3'b110: rd_data     <= (r1_data | imm_data);  //ori
                        3'b100: rd_data     <= (r1_data ^ imm_data);  //xori
                        3'b001: rd_data     <= (r1_data<<imm_data[4:0]);  //slli
                        3'b101: rd_data     <= subsra?(r1_data>>>imm_data[4:0]):(r1_data>>imm_data[4:0]);  //srai, srli
                        default: rd_data    <= 0;
                    endcase
                end
                7'b0110011: begin   //寄存器运算操作
                    dmem_addr   <= 0;
                    case(funccode)
                        3'b000: rd_data     <= subsra?(r1_data-r2_data):(r1_data+r2_data);  //sub, add
                        3'b010: rd_data     <= stl_res[31];  //stl
                        3'b011: rd_data     <= (r1_data < r2_data);  //stlu
                        3'b111: rd_data     <= (r1_data & r2_data);  //and
                        3'b110: rd_data     <= (r1_data | r2_data);  //or
                        3'b100: rd_data     <= (r1_data ^ r2_data);  //xor
                        3'b001: rd_data     <= (r1_data<<r2_data);  //sll
                        3'b101: rd_data     <= subsra?(r1_data>>>r2_data):(r1_data>>r2_data);  //sra, srl
                        default: rd_data    <= 0;
                    endcase
                end
                7'b0110111: begin
                    rd_data     <= imm_data;  //lui
                    dmem_addr   <= 0;
                end
                7'b0010111: begin
                    rd_data     <= pc_addr + imm_data;  //auipc
                    dmem_addr   <= 0;
                end
                7'b1101111: begin   //JAL
                    rd_data     <= pc_addr + 4;  
                    dmem_addr   <= 0;
                end
                7'b1100111: begin   //JALR
                    rd_data     <= pc_addr + 4; 
                    dmem_addr   <= 0;
                end
                7'b1100011: begin   //条件跳转指令
                    dmem_addr   <= 0;
                    case(funccode)
                        3'b000: begin
                            if(r1_data == r2_data) begin    //beq
                                rd_data     <= pc_addr + 4; 
                            end
                        end 
                        3'b001: begin
                            if(r1_data != r2_data) begin    //bne
                                rd_data     <= pc_addr + 4; 
                            end
                        end 
                        3'b100: begin
                            if(stl_res[31]) begin    //blt
                                rd_data     <= pc_addr + 4;
                            end
                        end 
                        3'b101: begin
                            if(~stl_res[31]) begin    //bge
                                rd_data     <= pc_addr + 4; 
                            end
                        end 
                        3'b110: begin
                            if(r1_data < r2_data) begin    //bltu
                                rd_data     <= pc_addr + 4; 
                            end
                        end 
                        3'b111: begin
                            if(r1_data >= r2_data) begin    //bgeu
                                rd_data     <= pc_addr + 4; 
                            end
                        end 
                        default: begin
                            rd_data     <= 0; 
                        end 
                    endcase
                end
                7'b0000011: begin   //载入指令
                    dmem_addr   <= r1_data + imm_data;
                    rd_data     <= 0;  //lb lbu lh lhu lw
                end
                7'b0100011: begin   //存储指令
                    dmem_addr   <= r1_data + imm_data;
                    case(funccode)
                        3'b000: rd_data     <= r2_data[31]?{24'hffffff,r2_data[7:0]}:{24'h000000,r2_data[7:0]};  //sb
                        3'b001: rd_data     <= r2_data[31]?{16'hffff,r2_data[15:0]}:{16'h0000,r2_data[15:0]};  //sh
                        3'b010: rd_data     <= r2_data;  //sw
                        default: rd_data     <= 0;
                    endcase
                end
                default: begin      //NOP
                    rd_data     <= 0; 
                    dmem_addr   <= 0;
                end
            endcase
    end
end
    
endmodule
