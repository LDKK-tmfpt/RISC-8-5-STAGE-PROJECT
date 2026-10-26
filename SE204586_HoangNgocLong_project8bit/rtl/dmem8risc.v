`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2026 09:12:10 AM
// Design Name: 
// Module Name: dmem8risc
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


module dmem8risc (
    input  wire       clk,
    input  wire       rst,
    input  wire       we,
    input  wire [7:0] addr,
    input  wire [7:0] wdata,
    output wire [7:0] rdata
);
    reg [7:0] ram [0:255];
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 256; i = i + 1)
                ram[i] <= 8'h00;
        end else if (we) begin
            ram[addr] <= wdata;
        end
    end

    assign rdata = ram[addr];
endmodule
