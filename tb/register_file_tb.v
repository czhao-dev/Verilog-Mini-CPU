`timescale 1ns / 1ps

module register_file_tb;
    reg clk;
    reg reset;
    reg write_enable;
    reg [1:0] write_addr;
    reg [3:0] write_data;
    reg [1:0] read_addr_a;
    reg [1:0] read_addr_b;
    wire [3:0] reg_a;
    wire [3:0] reg_b;
    integer failures;

    register_file uut (
        .clk(clk),
        .reset(reset),
        .write_enable(write_enable),
        .write_addr(write_addr),
        .write_data(write_data),
        .read_addr_a(read_addr_a),
        .read_addr_b(read_addr_b),
        .reg_a(reg_a),
        .reg_b(reg_b)
    );

    always #5 clk = ~clk;

    task expect_value;
        input [127:0] label;
        input [3:0] actual;
        input [3:0] expected;
        begin
            if (actual !== expected) begin
                $display("FAIL %0s: expected %h, got %h", label, expected, actual);
                failures = failures + 1;
            end
        end
    endtask

    task write_reg;
        input [1:0] addr;
        input [3:0] data;
        begin
            @(negedge clk);
            write_enable = 1'b1;
            write_addr = addr;
            write_data = data;
            @(negedge clk);
            write_enable = 1'b0;
        end
    endtask

    initial begin
        clk = 1'b0;
        failures = 0;
        reset = 1'b1;
        write_enable = 1'b0;
        write_addr = 2'b00;
        write_data = 4'b0000;
        read_addr_a = 2'b00;
        read_addr_b = 2'b01;

        #12 reset = 1'b0;
        #1;
        expect_value("reset R0", reg_a, 4'b0000);
        expect_value("reset R1", reg_b, 4'b0000);

        write_reg(2'd0, 4'ha);
        write_reg(2'd3, 4'h5);

        read_addr_a = 2'd0;
        read_addr_b = 2'd3;
        #1;
        expect_value("read R0", reg_a, 4'ha);
        expect_value("read R3", reg_b, 4'h5);

        reset = 1'b1;
        #10 reset = 1'b0;
        #1;
        expect_value("reset clears R0", reg_a, 4'b0000);
        expect_value("reset clears R3", reg_b, 4'b0000);

        if (failures == 0) begin
            $display("register_file_tb: PASS");
        end else begin
            $display("register_file_tb: FAIL (%0d failures)", failures);
            $finish_and_return(1);
        end

        $finish;
    end
endmodule
