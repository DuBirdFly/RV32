`include "defines.v"

module InstFetch(
    input                               clk,
    input                               rst,
    input                               hold,

    input wire                          jump_flag,
    input wire  [`InstCatchDepth-1:0]   jump_addr,

    output reg  [`InstCatchDepth-1:0]   pc

);

// 优先级: rst > jump_flag > hold
always @(posedge clk) begin
    if (rst) begin
        pc <= 'd0;
    end
    else if (jump_flag) begin
        pc <= jump_addr;
    end
    else if (~hold) begin
        pc <= pc + 'd4;
    end
end

endmodule




