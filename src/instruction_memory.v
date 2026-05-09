`timescale 1ns / 1ps

module instruction_memory (
    input wire clk,
    input wire reset,
    input wire write_enable,
    input wire [3:0] write_addr,
    input wire [15:0] write_data,
    input wire [3:0] read_addr,
    output wire [15:0] instruction
);
    reg [15:0] memory [0:15];
    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 16; i = i + 1) begin
                memory[i] <= 16'b0000_0000_0000_0000;
            end
        end else if (write_enable) begin
            memory[write_addr] <= write_data;
        end
    end

    assign instruction = memory[read_addr];
endmodule
