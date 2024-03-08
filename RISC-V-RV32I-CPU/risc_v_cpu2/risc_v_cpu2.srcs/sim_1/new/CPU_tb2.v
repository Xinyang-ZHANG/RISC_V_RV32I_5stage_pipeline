`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/04 22:42:09
// Design Name: 
// Module Name: CPU_tb2
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

//sum
module CPU_tb2();

reg         clk;
reg         rst;
//inst ram bus
reg [31:0]  inst_ram_waddr;    //13b useful
reg         inst_ram_wen;
reg [31:0]  inst_ram_wdata;
//data ram bus
reg [31:0]  data_ram_waddr;     //13b useful
reg         data_ram_wen;
reg [31:0]  data_ram_wdata;

reg [7:0]   cnt;
reg         start;

initial begin
    clk     <= 0;
    rst     <= 1;
    start   <= 0;
    cnt     <= 0;
    inst_ram_waddr  <= 0;
    inst_ram_wen    <= 0;
    inst_ram_wdata  <= 0;
    data_ram_waddr  <= 0;
    data_ram_wen    <= 0;
    data_ram_wdata  <= 0;
    
    #98
    rst     <= 0;
end

always#5    clk     <= ~clk;

//main counter
always@(posedge clk) begin
    if(rst) begin
        cnt         <= 0;
    end else begin
        if(cnt < 26)
            cnt     <= cnt + 1;
    end
end

//set intr and data address
always@(posedge clk) begin
    if(rst) begin
        inst_ram_waddr  <= 0;
        data_ram_waddr  <= 0;
    end else begin
        //init data
        if(cnt==1)
            data_ram_waddr  <= 32'h809;//1020h + 1004h = 2024h
        else
            data_ram_waddr  <= 0;
        //init intr
        if(cnt>2 && cnt<=12)
            inst_ram_waddr  <= inst_ram_waddr + 1;
        else
            inst_ram_waddr  <= 0;
    end
end

//set intr and data content
always@(posedge clk) begin
    if(rst) begin
        inst_ram_wen    <= 1;
        inst_ram_wdata  <= 0;
        data_ram_wen    <= 1;
        data_ram_wdata  <= 0;
    end else begin
        case(cnt)
            //init data
            0: begin
                inst_ram_wen    <= 1;
                inst_ram_wdata  <= 0;
                data_ram_wen    <= 1;
                data_ram_wdata  <= 0;
            end
            1: begin
                data_ram_wen    <= 1;
                data_ram_wdata  <= 32'h5678;
            end
            //init inst
            2: begin
                inst_ram_wen    <= 1;
                inst_ram_wdata  <= 32'h0052C2B3;    //xor
                data_ram_wen    <= 0;
                data_ram_wdata  <= 32'h0;
            end
            3: inst_ram_wdata  <= 32'h00634333;     //xor
            4: inst_ram_wdata  <= 32'h0073C3B3;     //xor
            5: inst_ram_wdata  <= 32'h00A38393;     //addi -> t2
            6: inst_ram_wdata  <= 32'h00735863;     //bge
            7: inst_ram_wdata  <= 32'h00128293;     //checkpoint: addi
            8: inst_ram_wdata  <= 32'h00628333;     //add
            9: inst_ram_wdata  <= 32'hFE734CE3;     //blt
            10: inst_ram_wdata  <= 32'h00001217;    //jointpoint: aupic
            11: inst_ram_wdata  <= 32'h00422F83;    //lw
            12: inst_ram_wdata  <= 32'h00100076;    //ebreak
            13: begin
                inst_ram_wen    <= 0;
                inst_ram_wdata  <= 0;
            end
            24: start           <= 1;
            25: start           <= 0;
            default: begin
                inst_ram_wen    <= 0;
                inst_ram_wdata  <= 0;
                data_ram_wen    <= 0;
                data_ram_wdata  <= 0;
            end
        endcase
    end
end

CPU     CPU_dut(
    .clk            (clk),
    .rst            (rst),
    .start          (start),
    .inst_ram_waddr (inst_ram_waddr),
    .inst_ram_wen   (inst_ram_wen),
    .inst_ram_wdata (inst_ram_wdata),
    .data_ram_waddr (data_ram_waddr),
    .data_ram_wen   (data_ram_wen),
    .data_ram_wdata (data_ram_wdata)
);

endmodule
