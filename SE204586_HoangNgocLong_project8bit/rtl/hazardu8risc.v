`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2026 09:14:39 AM
// Design Name: 
// Module Name: hazardu8risc
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


module hazardu8risc (

    input  wire       id_uses_a,
    input  wire       id_uses_b,
    input  wire [2:0] id_ra_addr,
    input  wire [2:0] id_rb_addr,
 
    input  wire       ex_valid,
    input  wire       ex_uses_a,
    input  wire       ex_uses_b,
    input  wire [2:0] ex_ra_addr,
    input  wire [2:0] ex_rb_addr,
    input  wire       ex_mem_to_reg,
    input  wire [2:0] ex_rd,

    input  wire       mem_valid,
    input  wire       mem_reg_we,
    input  wire       mem_mem_to_reg,
    input  wire [2:0] mem_rd,

    input  wire       wb_valid,
    input  wire       wb_reg_we,
    input  wire [2:0] wb_rd,

    output reg  [1:0] fwd_a_sel,
    output reg  [1:0] fwd_b_sel,
    output wire       stall
);

    always @(*) begin
        if (ex_valid && ex_uses_a) begin
            if (mem_valid && mem_reg_we && !mem_mem_to_reg && (mem_rd == ex_ra_addr))
                fwd_a_sel = 2'b01;
            else if (wb_valid && wb_reg_we && (wb_rd == ex_ra_addr))
                fwd_a_sel = 2'b10;
            else
                fwd_a_sel = 2'b00;
        end else begin
            fwd_a_sel = 2'b00;
        end
    end

    always @(*) begin
        if (ex_valid && ex_uses_b) begin
            if (mem_valid && mem_reg_we && !mem_mem_to_reg && (mem_rd == ex_rb_addr))
                fwd_b_sel = 2'b01;
            else if (wb_valid && wb_reg_we && (wb_rd == ex_rb_addr))
                fwd_b_sel = 2'b10;
            else
                fwd_b_sel = 2'b00;
        end else begin
            fwd_b_sel = 2'b00;
        end
    end

    assign stall = ex_valid && ex_mem_to_reg && (
                   (id_uses_a && (id_ra_addr == ex_rd)) ||
                   (id_uses_b && (id_rb_addr == ex_rd)) );
endmodule
