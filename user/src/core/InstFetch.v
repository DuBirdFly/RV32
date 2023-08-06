`include "defines.v"

module InstFetch(
    input               clk,
    input               rst,

    input               hold_IF,    // 导致下一拍的pc不变
    input  wire         nop,

    input  wire         jmp_vld,
    input  wire [31:0]  jmp_addr,

    output reg  [31:0]  pc,
    output wire [31:0]  inst

);

reg     [31:0]  cnt;
reg     [`InstCatchDepth-3:0]  rdaddr;   // addr[9:0] -> [11:2], 组合逻辑
wire    [31:0]  rddata;

assign inst = nop ? 32'h00000013 : rddata;

always @(posedge clk) begin
    if (rst)
        cnt <= 'd4;
    else if (jmp_vld)
        cnt <= jmp_addr + 'd4;
    else if (hold_IF)
        cnt <= cnt;
    else
        cnt <= cnt + 'd4;
end

always @(*) begin
    if (rst)
        rdaddr = 'd0;
    else if (jmp_vld)
        rdaddr = jmp_addr[`InstCatchDepth-1:2];
    else
        rdaddr = cnt[`InstCatchDepth-1:2];
end

always @(posedge clk) begin
    if (rst)
        pc <= 'd0;
    else if (jmp_vld)
        pc <= jmp_addr;
    else if (hold_IF)
        pc <= pc;
    else
        pc <= cnt;
end

InstCatch u_InstCatch(
    .clk      ( clk    ),
    .addr     ( rdaddr ),
    .inst     ( rddata )
);

endmodule