`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/24 23:38:03
// Design Name: 
// Module Name: CPU_tb
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


module CPU_tb();

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

always@(posedge clk) begin
    if(rst) begin
        cnt         <= 0;
    end else begin
        if(cnt < 26)
            cnt     <= cnt + 1;
    end
end

always@(posedge clk) begin
    if(rst) begin
        inst_ram_waddr  <= 0;
        data_ram_waddr  <= 0;
    end else begin
        //init data
        if(cnt>=1 && cnt<=2)
            data_ram_waddr  <= cnt-1;
        else
            data_ram_waddr  <= 0;
        //init intr
        if(cnt>3 && cnt<=14)
            inst_ram_waddr  <= inst_ram_waddr + 1;
        else if(cnt==15)
            inst_ram_waddr  <= inst_ram_waddr + 32'h100;    //after jal
        else
            inst_ram_waddr  <= 0;
    end
end

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
                data_ram_wdata  <= 32'h3;
            end
            2: data_ram_wdata  <= 32'h2;
            //init inst
            3: begin
                inst_ram_wen    <= 1;
                inst_ram_wdata  <= 32'h0002A283;
                data_ram_wen    <= 0;
                data_ram_wdata  <= 32'h0;
            end
            4: inst_ram_wdata  <= 32'h00132303;
            5,6,7: inst_ram_wdata  <= 32'h00000013;  //NOP
            8: inst_ram_wdata  <= 32'h006283B3;
            9: inst_ram_wdata  <= 32'h40628E33;
            10: inst_ram_wdata  <= 32'h0062FEB3;
            11: inst_ram_wdata  <= 32'h00532F33;
            12: inst_ram_wdata  <= 32'h0062DFB3;
            13: inst_ram_wdata  <= 32'h007E2423;
            14: inst_ram_wdata  <= 32'h400003EF;    //jal, immd*2+pc
            15: inst_ram_wdata  <= 32'h00100076;    //ebreak
            16: begin
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
