`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2026 09:18:06 AM
// Design Name: 
// Module Name: 8risc
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


module core8risc (
    input  wire       clk,
    input  wire       rst,
    output wire       halted,
    output wire [7:0] pc_out,
    output wire [1:0] flags_out,
    output wire       instr_done
);
    reg  [7:0]  pc;
    wire [15:0] if_instr;

    reg         ifid_valid;
    reg  [15:0] ifid_instr;

    wire [3:0] id_opcode = ifid_instr[15:12];
    wire [2:0] id_rd     = ifid_instr[11:9];
    wire [2:0] id_rs1    = ifid_instr[8:6];
    wire [2:0] id_rs2    = ifid_instr[5:3];
    wire [7:0] id_imm8   = ifid_instr[7:0];

    wire [2:0] id_alu_op;
    wire       id_alu_src_imm, id_ra_is_rd, id_rb_is_rd, id_uses_a, id_uses_b;
    wire       id_reg_we, id_mem_to_reg, id_mem_we, id_flag_we;
    wire       id_jump, id_br_z, id_br_nz, id_halt;

    wire [2:0] id_ra_addr = id_ra_is_rd ? id_rd : id_rs1;
    wire [2:0] id_rb_addr = id_rb_is_rd ? id_rd : id_rs2;
    wire [7:0] id_ra_data, id_rb_data;

    reg        idex_valid;
    reg  [2:0] idex_alu_op;
    reg        idex_alu_src_imm, idex_uses_a, idex_uses_b;
    reg        idex_reg_we, idex_mem_to_reg, idex_mem_we, idex_flag_we;
    reg        idex_jump, idex_br_z, idex_br_nz, idex_halt;
    reg  [2:0] idex_rd, idex_ra_addr, idex_rb_addr;
    reg  [7:0] idex_ra_data, idex_rb_data, idex_imm8;

    wire [1:0] fwd_a_sel, fwd_b_sel;
    wire       stall;
    reg  [7:0] ex_opa, ex_opb_reg;
    wire [7:0] ex_opb;
    wire [7:0] ex_alu_result;
    wire       ex_alu_z, ex_alu_c;
    reg        flag_z, flag_c;

    wire       ex_z_now    = (idex_valid && idex_flag_we) ? ex_alu_z : flag_z;
    wire       take_branch = idex_valid && (idex_jump || (idex_br_z && ex_z_now) || (idex_br_nz && !ex_z_now));
    wire [7:0] branch_target = idex_imm8;

    reg        exmem_valid;
    reg        exmem_reg_we, exmem_mem_to_reg, exmem_mem_we, exmem_halt;
    reg  [2:0] exmem_rd;
    reg  [7:0] exmem_alu_result, exmem_addr, exmem_st_data;

    wire [7:0] mem_rdata;
    wire [7:0] mem_result = exmem_mem_to_reg ? mem_rdata : exmem_alu_result;

    reg        memwb_valid;
    reg        memwb_reg_we, memwb_halt;
    reg  [2:0] memwb_rd;
    reg  [7:0] memwb_result;

    // --- Khởi tạo các Module con ---
    imem8risc u_imem (
        .addr  (pc),
        .instr (if_instr)
    );

    ctrlu8risc u_ctrl (
        .opcode      (id_opcode),
        .alu_op      (id_alu_op),
        .alu_src_imm (id_alu_src_imm),
        .ra_is_rd    (id_ra_is_rd),
        .rb_is_rd    (id_rb_is_rd),
        .uses_a      (id_uses_a),
        .uses_b      (id_uses_b),
        .reg_we      (id_reg_we),
        .mem_to_reg  (id_mem_to_reg),
        .mem_we      (id_mem_we),
        .flag_we     (id_flag_we),
        .jump        (id_jump),
        .br_z        (id_br_z),
        .br_nz       (id_br_nz),
        .halt        (id_halt)
    );

    regfile8risc u_regfile (
        .clk     (clk),
        .rst     (rst),
        .ra_addr (id_ra_addr),
        .rb_addr (id_rb_addr),
        .ra_data (id_ra_data),
        .rb_data (id_rb_data),
        .we      (memwb_valid && memwb_reg_we),
        .w_addr  (memwb_rd),
        .w_data  (memwb_result)
    );

    hazardu8risc u_hazard (
        .id_uses_a      (ifid_valid && id_uses_a),
        .id_uses_b      (ifid_valid && id_uses_b),
        .id_ra_addr     (id_ra_addr),
        .id_rb_addr     (id_rb_addr),
        .ex_valid       (idex_valid),
        .ex_uses_a      (idex_uses_a),
        .ex_uses_b      (idex_uses_b),
        .ex_ra_addr     (idex_ra_addr),
        .ex_rb_addr     (idex_rb_addr),
        .ex_mem_to_reg  (idex_mem_to_reg),
        .ex_rd          (idex_rd),
        .mem_valid      (exmem_valid),
        .mem_reg_we     (exmem_reg_we),
        .mem_mem_to_reg (exmem_mem_to_reg),
        .mem_rd         (exmem_rd),
        .wb_valid       (memwb_valid),
        .wb_reg_we      (memwb_reg_we),
        .wb_rd          (memwb_rd),
        .fwd_a_sel      (fwd_a_sel),
        .fwd_b_sel      (fwd_b_sel),
        .stall          (stall)
    );

    always @(*) begin
        case (fwd_a_sel)
            2'b01:   ex_opa = exmem_alu_result;
            2'b10:   ex_opa = memwb_result;
            default: ex_opa = idex_ra_data;
        endcase
        case (fwd_b_sel)
            2'b01:   ex_opb_reg = exmem_alu_result;
            2'b10:   ex_opb_reg = memwb_result;
            default: ex_opb_reg = idex_rb_data;
        endcase
    end

    assign ex_opb = idex_alu_src_imm ? idex_imm8 : ex_opb_reg;

    alu8risc u_alu (
        .a      (ex_opa),
        .b      (ex_opb),
        .alu_op (idex_alu_op),
        .result (ex_alu_result),
        .z      (ex_alu_z),
        .c      (ex_alu_c)
    );

    dmem8risc u_dmem (
        .clk   (clk),
        .rst   (rst),
        .we    (exmem_valid && exmem_mem_we),
        .addr  (exmem_addr),
        .wdata (exmem_st_data),
        .rdata (mem_rdata)
    );

    wire halt_in_pipe = (idex_valid && idex_halt) || (exmem_valid && exmem_halt) || (memwb_valid && memwb_halt);

    always @(posedge clk) begin
        if (rst) begin
            pc               <= 8'h00;
            ifid_valid       <= 1'b0;
            ifid_instr       <= 16'h0000;
            idex_valid       <= 1'b0;
            idex_alu_op      <= 3'd0;
            idex_alu_src_imm <= 1'b0;
            idex_uses_a      <= 1'b0;
            idex_uses_b      <= 1'b0;
            idex_reg_we      <= 1'b0;
            idex_mem_to_reg  <= 1'b0;
            idex_mem_we      <= 1'b0;
            idex_flag_we     <= 1'b0;
            idex_jump        <= 1'b0;
            idex_br_z        <= 1'b0;
            idex_br_nz       <= 1'b0;
            idex_halt        <= 1'b0;
            idex_rd          <= 3'd0;
            idex_ra_addr     <= 3'd0;
            idex_rb_addr     <= 3'd0;
            idex_ra_data     <= 8'h00;
            idex_rb_data     <= 8'h00;
            idex_imm8        <= 8'h00;
            exmem_valid      <= 1'b0;
            exmem_reg_we     <= 1'b0;
            exmem_mem_to_reg <= 1'b0;
            exmem_mem_we     <= 1'b0;
            exmem_halt       <= 1'b0;
            exmem_rd         <= 3'd0;
            exmem_alu_result <= 8'h00;
            exmem_addr       <= 8'h00;
            exmem_st_data    <= 8'h00;
            memwb_valid      <= 1'b0;
            memwb_reg_we     <= 1'b0;
            memwb_halt       <= 1'b0;
            memwb_rd         <= 3'd0;
            memwb_result     <= 8'h00;
            flag_z           <= 1'b0;
            flag_c           <= 1'b0;
        end else if (!halted) begin
            if (take_branch) begin
                pc         <= branch_target;
                ifid_valid <= 1'b0;
                ifid_instr <= 16'h0000;
            end else if (halt_in_pipe) begin
                pc         <= pc;
                ifid_valid <= 1'b0;
                ifid_instr <= 16'h0000;
            end else if (stall) begin
                pc         <= pc;
                ifid_valid <= ifid_valid;
                ifid_instr <= ifid_instr;
            end else begin
                pc         <= pc + 8'd1;
                ifid_valid <= 1'b1;
                ifid_instr <= if_instr;
            end

            if (take_branch || halt_in_pipe || stall || !ifid_valid) begin
                idex_valid       <= 1'b0;
                idex_reg_we      <= 1'b0;
                idex_mem_to_reg  <= 1'b0;
                idex_mem_we      <= 1'b0;
                idex_flag_we     <= 1'b0;
                idex_jump        <= 1'b0;
                idex_br_z        <= 1'b0;
                idex_br_nz       <= 1'b0;
                idex_halt        <= 1'b0;
            end else begin
                idex_valid       <= 1'b1;
                idex_alu_op      <= id_alu_op;
                idex_alu_src_imm <= id_alu_src_imm;
                idex_uses_a      <= id_uses_a;
                idex_uses_b      <= id_uses_b;
                idex_reg_we      <= id_reg_we;
                idex_mem_to_reg  <= id_mem_to_reg;
                idex_mem_we      <= id_mem_we;
                idex_flag_we     <= id_flag_we;
                idex_jump        <= id_jump;
                idex_br_z        <= id_br_z;
                idex_br_nz       <= id_br_nz;
                idex_halt        <= id_halt;
                idex_rd          <= id_rd;
                idex_ra_addr     <= id_ra_addr;
                idex_rb_addr     <= id_rb_addr;
                idex_ra_data     <= id_ra_data;
                idex_rb_data     <= id_rb_data;
                idex_imm8        <= id_imm8;
            end

            if (idex_valid && idex_flag_we) begin
                flag_z <= ex_alu_z;
                flag_c <= ex_alu_c;
            end

            exmem_valid      <= idex_valid;
            exmem_reg_we     <= idex_valid ? idex_reg_we     : 1'b0;
            exmem_mem_to_reg <= idex_valid ? idex_mem_to_reg : 1'b0;
            exmem_mem_we     <= idex_valid ? idex_mem_we     : 1'b0;
            exmem_halt       <= idex_valid ? idex_halt       : 1'b0;
            exmem_rd         <= idex_rd;
            exmem_alu_result <= ex_alu_result;
            exmem_addr       <= ex_opa;
            exmem_st_data    <= ex_opb_reg;

            memwb_valid      <= exmem_valid;
            memwb_reg_we     <= exmem_valid ? exmem_reg_we : 1'b0;
            memwb_halt       <= exmem_valid ? exmem_halt   : 1'b0;
            memwb_rd         <= exmem_rd;
            memwb_result     <= mem_result;
        end
    end

    assign halted     = memwb_valid && memwb_halt;
    assign pc_out     = pc;
    assign flags_out  = {flag_z, flag_c};
    assign instr_done = memwb_valid;
endmodule
