`timescale 1ns / 1ps

module top (
    input wire clk,
    input wire reset,
    input wire run_enable,
    input wire reg_write_enable,
    input wire [1:0] reg_write_addr,
    input wire [3:0] reg_write_data,
    input wire instr_write_enable,
    input wire [3:0] instr_write_addr,
    input wire [15:0] instr_write_data,
    output reg [3:0] pc,
    output wire [15:0] instruction,
    output wire [3:0] result,
    output wire zero,
    output wire negative,
    output wire carry,
    output wire overflow
);
    wire [1:0] dest_addr, src_a_addr, src_b_addr;
    wire [2:0] alu_op;
    wire use_immediate;
    wire [3:0] immediate;
    wire [3:0] a, b, alu_b;
    wire cpu_step;
    wire rf_write_enable;
    wire [1:0] rf_write_addr;
    wire [3:0] rf_write_data;

    instruction_memory imem (
        .clk(clk),
        .reset(reset),
        .write_enable(instr_write_enable),
        .write_addr(instr_write_addr),
        .write_data(instr_write_data),
        .read_addr(pc),
        .instruction(instruction)
    );

    control_unit cu (
        .instruction(instruction),
        .alu_op(alu_op),
        .dest_addr(dest_addr),
        .src_a_addr(src_a_addr),
        .src_b_addr(src_b_addr),
        .use_immediate(use_immediate),
        .immediate(immediate)
    );

    assign cpu_step = run_enable & ~reg_write_enable & ~instr_write_enable;
    assign rf_write_enable = reg_write_enable | cpu_step;
    assign rf_write_addr = reg_write_enable ? reg_write_addr : dest_addr;
    assign rf_write_data = reg_write_enable ? reg_write_data : result;

    register_file rf (
        .clk(clk),
        .reset(reset),
        .write_enable(rf_write_enable),
        .write_addr(rf_write_addr),
        .write_data(rf_write_data),
        .read_addr_a(src_a_addr),
        .read_addr_b(src_b_addr),
        .reg_a(a),
        .reg_b(b)
    );

    assign alu_b = use_immediate ? immediate : b;

    alu alu_inst (
        .a(a),
        .b(alu_b),
        .op(alu_op),
        .result(result),
        .zero(zero),
        .negative(negative),
        .carry(carry),
        .overflow(overflow)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 4'b0000;
        end else if (cpu_step) begin
            pc <= pc + 4'b0001;
        end
    end
endmodule
