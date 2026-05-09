`timescale 1ns / 1ps

module alu_tb;
    reg [3:0] a;
    reg [3:0] b;
    reg [2:0] op;
    wire [3:0] result;
    wire zero;
    wire negative;
    wire carry;
    wire overflow;
    integer failures;

    alu uut (
        .a(a),
        .b(b),
        .op(op),
        .result(result),
        .zero(zero),
        .negative(negative),
        .carry(carry),
        .overflow(overflow)
    );

    task check;
        input [127:0] label;
        input [3:0] expected_result;
        input expected_zero;
        input expected_negative;
        input expected_carry;
        input expected_overflow;
        begin
            #1;
            if (result !== expected_result ||
                zero !== expected_zero ||
                negative !== expected_negative ||
                carry !== expected_carry ||
                overflow !== expected_overflow) begin
                $display(
                    "FAIL %0s: result=%h zero=%b negative=%b carry=%b overflow=%b",
                    label, result, zero, negative, carry, overflow
                );
                failures = failures + 1;
            end
        end
    endtask

    initial begin
        failures = 0;

        a = 4'd4; b = 4'd5; op = 3'b000; check("ADD", 4'd9, 1'b0, 1'b1, 1'b0, 1'b1);
        a = 4'd4; b = 4'd5; op = 3'b001; check("SUB", 4'hf, 1'b0, 1'b1, 1'b1, 1'b0);
        a = 4'b1100; b = 4'b1010; op = 3'b010; check("AND", 4'b1000, 1'b0, 1'b1, 1'b0, 1'b0);
        a = 4'b1100; b = 4'b1010; op = 3'b011; check("OR", 4'b1110, 1'b0, 1'b1, 1'b0, 1'b0);
        a = 4'b1100; b = 4'b1010; op = 3'b100; check("XOR", 4'b0110, 1'b0, 1'b0, 1'b0, 1'b0);
        a = 4'b1000; b = 4'd1; op = 3'b101; check("SLL", 4'b0000, 1'b1, 1'b0, 1'b1, 1'b0);
        a = 4'b0001; b = 4'd1; op = 3'b110; check("SRL", 4'b0000, 1'b1, 1'b0, 1'b1, 1'b0);
        a = 4'd4; b = 4'd5; op = 3'b111; check("SLT true", 4'b0001, 1'b0, 1'b0, 1'b0, 1'b0);
        a = 4'd5; b = 4'd4; op = 3'b111; check("SLT false", 4'b0000, 1'b1, 1'b0, 1'b0, 1'b0);

        if (failures == 0) begin
            $display("alu_tb: PASS");
        end else begin
            $display("alu_tb: FAIL (%0d failures)", failures);
            $finish_and_return(1);
        end

        $finish;
    end
endmodule
