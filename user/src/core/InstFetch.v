`include "defines.v"

module InstFetch(
    input               clk,
    input               rst,

    input  wire         jump_flag,
    input  wire [31:0]  jump_addr,

    output reg  [31:0]  pc,
    output wire [31:0]  inst

);

reg     [31:0]  cnt;
reg     [`InstCatchDepth-3:0]  rdaddr;   // addr[9:0] -> [11:2], 组合逻辑

always @(posedge clk) begin
    if (rst)
        cnt <= 'd4;
    else if (jump_flag)
        cnt <= jump_addr + 4;
    else
        cnt <= cnt + 'd4;
end

always @(*) begin
    if (rst)
        rdaddr = 'd0;
    else if (jump_flag)
        rdaddr = jump_addr[`InstCatchDepth-1:2];
    else
        rdaddr = cnt[`InstCatchDepth:2];
end

always @(posedge clk) begin
    if (rst)
        pc <= 'd0;
    else if (jump_flag)
        pc <= jump_addr;
    else
        pc <= cnt;
end

InstCatch u_InstCatch(
    .clk      ( clk    ),
    .addr     ( rdaddr ),
    .inst     ( inst   )
);

endmodule