`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2026 09:15:52 AM
// Design Name: 
// Module Name: imem8risc
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


module imem8risc (
    input  wire [7:0]  addr,
    output reg  [15:0] instr
);
    always @(*) begin
        case (addr)
        
            8'h00: instr = 16'h8420;
            8'h01: instr = 16'h820F;
            8'h02: instr = 16'h8133;
            8'h03: instr = 16'h3650;
            8'h04: instr = 16'h4C50;
            8'h05: instr = 16'h5C50;
            8'h06: instr = 16'h76C0;
            8'h07: instr = 16'h6CC0;
            8'h08: instr = 16'hB500;

            8'h09: instr = 16'hAB00;
            8'h0A: instr = 16'h9AF0;
            8'h0B: instr = 16'h9A01;

            8'h0C: instr = 16'hD00F;
            8'h0D: instr = 16'h8EFF;
            8'h0E: instr = 16'h8EFF;

            8'h0F: instr = 16'h8205;
            8'h10: instr = 16'h8C00;

            8'h11: instr = 16'h1D88;
            8'h12: instr = 16'h2258;
            8'h13: instr = 16'hE011;

            8'h14: instr = 16'h9C57;
            8'h15: instr = 16'h9A00;
            8'h16: instr = 16'h2A98;
            8'h17: instr = 16'h9AF2; 
            8'h18: instr = 16'hC01A; 
            8'h19: instr = 16'h8EFF; 
            8'h1A: instr = 16'h0000;
            8'h1B: instr = 16'hF000;
            default: instr = 16'h0000;
        endcase
    end
endmodule
