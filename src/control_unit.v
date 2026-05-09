`timescale 1ns / 1ps

module control_unit (
    input wire [15:0] instruction,
    output wire [2:0] alu_op,
    output wire [1:0] dest_addr,
    output wire [1:0] src_a_addr,
    output wire [1:0] src_b_addr,
    output wire use_immediate,
    output wire [3:0] immediate
);

    assign alu_op = instruction[15:13];
    assign dest_addr = instruction[12:11];
    assign src_a_addr = instruction[10:9];
    assign src_b_addr = instruction[8:7];
    assign use_immediate = instruction[6];
    assign immediate = instruction[3:0];
endmodule
