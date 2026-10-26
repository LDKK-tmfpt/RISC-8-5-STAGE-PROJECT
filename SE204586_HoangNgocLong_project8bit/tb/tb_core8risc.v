`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2026 09:21:46 AM
// Design Name: 
// Module Name: tb_core8risc
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


module tb_core8risc;
    reg        clk;
    reg        rst;
    wire       halted;
    wire [7:0] pc_out;
    wire [1:0] flags_out;
    wire       instr_done;

    integer cycle_cnt;
    integer instr_cnt;
    integer err_cnt;

    core8risc dut (
        .clk        (clk),
        .rst        (rst),
        .halted     (halted),
        .pc_out     (pc_out),
        .flags_out  (flags_out),
        .instr_done (instr_done)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        rst       = 1'b1;
        cycle_cnt = 0;
        instr_cnt = 0;
        err_cnt   = 0;

        #25;
        rst = 1'b0;
    end

    always @(posedge clk) begin
        if (!rst) begin
            cycle_cnt = cycle_cnt + 1;
            if (instr_done)
                instr_cnt = instr_cnt + 1;

            $display("Cycle %02d | PC=0x%02h | IF/ID_v=%b | Stall=%b | Branch=%b | WB_done=%b | Z=%b C=%b",
                     cycle_cnt, pc_out, dut.ifid_valid, dut.stall, dut.take_branch,
                     instr_done, flags_out[1], flags_out[0]);

            if (halted) begin
                $display("------------------------------------------------------------");
                $display("Program halted at cycle %0d, instructions completed: %0d", cycle_cnt, instr_cnt);

                if (dut.u_regfile.regs[1] !== 8'h00) begin $display("FAIL R1: exp 0x00, got 0x%02h", dut.u_regfile.regs[1]); err_cnt = err_cnt + 1; end
                if (dut.u_regfile.regs[2] !== 8'h0F) begin $display("FAIL R2: exp 0x0F, got 0x%02h", dut.u_regfile.regs[2]); err_cnt = err_cnt + 1; end
                if (dut.u_regfile.regs[3] !== 8'h01) begin $display("FAIL R3: exp 0x01, got 0x%02h", dut.u_regfile.regs[3]); err_cnt = err_cnt + 1; end
                if (dut.u_regfile.regs[4] !== 8'h20) begin $display("FAIL R4: exp 0x20, got 0x%02h", dut.u_regfile.regs[4]); err_cnt = err_cnt + 1; end
                if (dut.u_regfile.regs[5] !== 8'h00) begin $display("FAIL R5: exp 0x00, got 0x%02h", dut.u_regfile.regs[5]); err_cnt = err_cnt + 1; end
                if (dut.u_regfile.regs[6] !== 8'h66) begin $display("FAIL R6: exp 0x66, got 0x%02h", dut.u_regfile.regs[6]); err_cnt = err_cnt + 1; end
                if (dut.u_regfile.regs[7] !== 8'h00) begin $display("FAIL R7: exp 0x00, got 0x%02h", dut.u_regfile.regs[7]); err_cnt = err_cnt + 1; end
                if (dut.u_dmem.ram[8'h20] !== 8'h0F) begin $display("FAIL MEM[0x20]: exp 0x0F, got 0x%02h", dut.u_dmem.ram[8'h20]); err_cnt = err_cnt + 1; end
                if (flags_out !== 2'b11)             begin $display("FAIL Flags Z,C: exp 11, got %b", flags_out); err_cnt = err_cnt + 1; end

                if (err_cnt == 0)
                    $display("*** ALL TESTS PASSED ***");
                else
                    $display("*** TEST FAILED WITH %0d ERRORS ***", err_cnt);
                $display("------------------------------------------------------------");
                $finish;
            end
        end
    end
endmodule
