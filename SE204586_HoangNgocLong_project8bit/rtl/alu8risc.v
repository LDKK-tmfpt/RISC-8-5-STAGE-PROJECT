`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2026 09:09:54 AM
// Design Name: 
// Module Name: alu8risc
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


module alu8risc (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [2:0] alu_op,
    output reg  [7:0] result,
    output wire       z,
    output reg        c
);
    reg [8:0] tmp;

    always @(*) begin
        result = 8'h00;
        c      = 1'b0;
        tmp    = 9'h000;
        case (alu_op)
            3'd0: begin
                tmp    = {1'b0, a} + {1'b0, b};
                result = tmp[7:0];
                c      = tmp[8];
            end
            3'd1: begin
                tmp    = {1'b0, a} - {1'b0, b};
                result = tmp[7:0];
                c      = (a < b);
            end
            3'd2: result = a & b;
            3'd3: result = a | b;
            3'd4: result = a ^ b;
            3'd5: begin
                c      = a[7];
                result = {a[6:0], 1'b0};
            end
            3'd6: begin
                c      = a[0];
                result = {1'b0, a[7:1]};
            end
            3'd7: result = b;
            default: result = 8'h00;
        endcase
    end

    assign z = (result == 8'h00);
endmodule
