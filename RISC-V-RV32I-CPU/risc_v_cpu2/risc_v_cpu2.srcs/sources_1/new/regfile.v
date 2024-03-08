`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/22 22:17:58
// Design Name: 
// Module Name: regfile
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


module regfile(
    input           clk,
    input           rst,
    input   [4:0]   r1_addr,
    input   [4:0]   r2_addr,
    output  [31:0]  r1_data,
    output  [31:0]  r2_data,
    input           rd_wren,
    input   [4:0]   rd_addr,
    input   [31:0]  rd_data
);

genvar  i;  
reg [31:0]  regdata     [31:0];

initial begin
    regdata[0]      <= 0;
end
        
generate
    for(i=1; i<32; i=i+1) begin
        initial begin
            regdata[i]      <= 0;
        end
        always@(negedge clk) begin
            if(rst) begin
                regdata[i]      <= 0;
            end else begin
                if((rd_addr==i) && rd_wren) begin
                    regdata[i]  <= rd_data;
                end
            end
        end
    end
endgenerate

assign  r1_data = regdata[r1_addr];
assign  r2_data = regdata[r2_addr];
    
endmodule
