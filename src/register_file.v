`timescale 1ns / 1ps

module register_file (
    input wire clk,
    input wire reset,
    input wire write_enable,
    input wire [1:0] write_addr,
    input wire [3:0] write_data,
    input wire [1:0] read_addr_a,
    input wire [1:0] read_addr_b,
    output wire [3:0] reg_a,
    output wire [3:0] reg_b
);
    reg [3:0] registers [0:3];
    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 4; i = i + 1) begin
                registers[i] <= 4'b0000;
            end
        end else if (write_enable) begin
            registers[write_addr] <= write_data;
        end
    end

    assign reg_a = registers[read_addr_a];
    assign reg_b = registers[read_addr_b];
endmodule
