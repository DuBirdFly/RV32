module InstFetch(
    input                               clk,
    input                               rst,
    input                               hold,

    input wire                          jump_flag,
    input wire  [`InstCatchDepth-1:0]   jump_addr,

    output reg  [`InstCatchDepth-1:0]   pc

);

always @(posedge clk) begin
    if (rst) begin
        pc <= 0;
    end
    else if (~hold) begin
        if (jump_flag)
            pc <= jump_addr;
        else
            pc <= pc + 'd4;
    end
end

endmodule




