`timescale 1ns / 1ps

module alu (
    input wire [3:0] a,
    input wire [3:0] b,
    input wire [2:0] op,
    output reg [3:0] result,
    output wire zero,
    output wire negative,
    output reg carry,
    output reg overflow
);
    reg [4:0] extended_result;

    always @(*) begin
        result = 4'b0000;
        carry = 1'b0;
        overflow = 1'b0;
        extended_result = 5'b00000;

        case (op)
            3'b000: begin // ADD
                extended_result = {1'b0, a} + {1'b0, b};
                result = extended_result[3:0];
                carry = extended_result[4];
                overflow = (a[3] == b[3]) && (result[3] != a[3]);
            end
            3'b001: begin // SUB
                extended_result = {1'b0, a} - {1'b0, b};
                result = extended_result[3:0];
                carry = (a < b);
                overflow = (a[3] != b[3]) && (result[3] != a[3]);
            end
            3'b010: result = a & b; // AND
            3'b011: result = a | b; // OR
            3'b100: result = a ^ b; // XOR
            3'b101: begin // SLL
                result = a << b[1:0];
                case (b[1:0])
                    2'b01: carry = a[3];
                    2'b10: carry = a[2];
                    2'b11: carry = a[1];
                    default: carry = 1'b0;
                endcase
            end
            3'b110: begin // SRL
                result = a >> b[1:0];
                case (b[1:0])
                    2'b01: carry = a[0];
                    2'b10: carry = a[1];
                    2'b11: carry = a[2];
                    default: carry = 1'b0;
                endcase
            end
            3'b111: result = (a < b) ? 4'b0001 : 4'b0000; // SLT
            default: result = 4'b0000;
        endcase
    end

    assign zero = (result == 4'b0000);
    assign negative = result[3];

endmodule
