`timescale 1ns / 1ps

module top_tb;
    reg clk;
    reg reset;
    reg run_enable;
    reg reg_write_enable;
    reg [1:0] reg_write_addr;
    reg [3:0] reg_write_data;
    reg instr_write_enable;
    reg [3:0] instr_write_addr;
    reg [15:0] instr_write_data;
    wire [3:0] pc;
    wire [15:0] instruction;
    wire [3:0] result;
    wire zero;
    wire negative;
    wire carry;
    wire overflow;
    integer failures;

    top uut (
        .clk(clk),
        .reset(reset),
        .run_enable(run_enable),
        .reg_write_enable(reg_write_enable),
        .reg_write_addr(reg_write_addr),
        .reg_write_data(reg_write_data),
        .instr_write_enable(instr_write_enable),
        .instr_write_addr(instr_write_addr),
        .instr_write_data(instr_write_data),
        .pc(pc),
        .instruction(instruction),
        .result(result),
        .zero(zero),
        .negative(negative),
        .carry(carry),
        .overflow(overflow)
    );

    always #5 clk = ~clk;

    function [15:0] encode;
        input [2:0] opcode;
        input [1:0] dest;
        input [1:0] src_a;
        input [1:0] src_b;
        input use_immediate;
        input [3:0] immediate;
        begin
            encode = {opcode, dest, src_a, src_b, use_immediate, 2'b00, immediate};
        end
    endfunction

    task expect_equal;
        input [127:0] label;
        input [15:0] actual;
        input [15:0] expected;
        begin
            if (actual !== expected) begin
                $display("FAIL %0s: expected %h, got %h", label, expected, actual);
                failures = failures + 1;
            end
        end
    endtask

    task write_register;
        input [1:0] addr;
        input [3:0] data;
        begin
            @(negedge clk);
            reg_write_enable = 1'b1;
            reg_write_addr = addr;
            reg_write_data = data;
            @(negedge clk);
            reg_write_enable = 1'b0;
        end
    endtask

    task write_instruction;
        input [3:0] addr;
        input [15:0] data;
        begin
            @(negedge clk);
            instr_write_enable = 1'b1;
            instr_write_addr = addr;
            instr_write_data = data;
            @(negedge clk);
            instr_write_enable = 1'b0;
        end
    endtask

    task run_step;
        input [3:0] expected_pc_before;
        input [3:0] expected_result;
        input expected_zero;
        input expected_negative;
        input expected_carry;
        input expected_overflow;
        input [1:0] expected_dest;
        input [3:0] expected_writeback;
        begin
            @(negedge clk);
            run_enable = 1'b1;
            #1;
            expect_equal("pc before step", pc, expected_pc_before);
            expect_equal("result before step", result, expected_result);
            expect_equal("zero before step", zero, expected_zero);
            expect_equal("negative before step", negative, expected_negative);
            expect_equal("carry before step", carry, expected_carry);
            expect_equal("overflow before step", overflow, expected_overflow);
            @(posedge clk);
            #1;
            expect_equal("pc after step", pc, expected_pc_before + 1'b1);
            expect_equal("writeback", uut.rf.registers[expected_dest], expected_writeback);
            @(negedge clk);
            run_enable = 1'b0;
        end
    endtask

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, top_tb);

        clk = 1'b0;
        failures = 0;
        reset = 1'b1;
        run_enable = 1'b0;
        reg_write_enable = 1'b0;
        reg_write_addr = 2'b00;
        reg_write_data = 4'b0000;
        instr_write_enable = 1'b0;
        instr_write_addr = 4'b0000;
        instr_write_data = 16'b0000_0000_0000_0000;

        #12 reset = 1'b0;

        write_register(2'd0, 4'd4);
        write_register(2'd1, 4'd5);

        write_instruction(4'd0, encode(3'b000, 2'd2, 2'd0, 2'd1, 1'b0, 4'd0)); // R2 = R0 + R1
        write_instruction(4'd1, encode(3'b001, 2'd3, 2'd0, 2'd1, 1'b0, 4'd0)); // R3 = R0 - R1
        write_instruction(4'd2, encode(3'b010, 2'd2, 2'd2, 2'd0, 1'b1, 4'd8)); // R2 = R2 & 8
        write_instruction(4'd3, encode(3'b101, 2'd2, 2'd2, 2'd0, 1'b1, 4'd1)); // R2 = R2 << 1
        write_instruction(4'd4, encode(3'b111, 2'd3, 2'd0, 2'd1, 1'b0, 4'd0)); // R3 = R0 < R1

        run_step(4'd0, 4'd9, 1'b0, 1'b1, 1'b0, 1'b1, 2'd2, 4'd9);
        run_step(4'd1, 4'hf, 1'b0, 1'b1, 1'b1, 1'b0, 2'd3, 4'hf);
        run_step(4'd2, 4'd8, 1'b0, 1'b1, 1'b0, 1'b0, 2'd2, 4'd8);
        run_step(4'd3, 4'd0, 1'b1, 1'b0, 1'b1, 1'b0, 2'd2, 4'd0);
        run_step(4'd4, 4'd1, 1'b0, 1'b0, 1'b0, 1'b0, 2'd3, 4'd1);

        if (failures == 0) begin
            $display("top_tb: PASS");
        end else begin
            $display("top_tb: FAIL (%0d failures)", failures);
            $finish_and_return(1);
        end

        $finish;
    end
endmodule
