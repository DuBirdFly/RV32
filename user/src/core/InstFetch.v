`include "defines.v"

module InstFetch(
    input               clk,
    input               rst,
    input               hold,

    input  wire         jmp_vld,
    input  wire [31:0]  jmp_addr,

    output reg  [31:0]  pc,
    output wire [31:0]  inst

);

reg     [31:0]  cnt;
reg     [`InstCatchDepth-3:0]  rdaddr;   // addr[9:0] -> [11:2], 组合逻辑

always @(posedge clk) begin
    if (rst)
        cnt <= 'd4;
    else if (jmp_vld)
        cnt <= jmp_addr + 4;
    else if (!hold)
        cnt <= cnt + 'd4;
end

always @(*) begin
    if (rst)
        rdaddr = 'd0;
    else if (jmp_vld)
        rdaddr = jmp_addr[`InstCatchDepth-1:2];
    else
        rdaddr = cnt[`InstCatchDepth:2];
end

always @(posedge clk) begin
    if (rst)
        pc <= 'd0;
    else if (jmp_vld)
        pc <= jmp_addr;
    else if (!hold)
        pc <= cnt;
end

InstCatch u_InstCatch(
    .clk      ( clk    ),
    .addr     ( rdaddr ),
    .inst     ( inst   )
);

endmodule