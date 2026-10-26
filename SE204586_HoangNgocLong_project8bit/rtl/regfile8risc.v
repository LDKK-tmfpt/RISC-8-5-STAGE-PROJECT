`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2026 09:10:48 AM
// Design Name: 
// Module Name: regfile8risc
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


module regfile8risc (
    input  wire       clk,
    input  wire       rst,
    input  wire [2:0] ra_addr,
    input  wire [2:0] rb_addr,
    output wire [7:0] ra_data,
    output wire [7:0] rb_data,
    input  wire       we,
    input  wire [2:0] w_addr,
    input  wire [7:0] w_data
);
    reg [7:0] regs [0:7];
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 8; i = i + 1)
                regs[i] <= 8'h00;
        end else if (we) begin
            regs[w_addr] <= w_data;
        end
    end

    assign ra_data = (we && (w_addr == ra_addr)) ? w_data : regs[ra_addr];
    assign rb_data = (we && (w_addr == rb_addr)) ? w_data : regs[rb_addr];
endmodule
