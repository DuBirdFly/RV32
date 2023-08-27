// `include "../inc/defines.v"
`include "defines.v"

// 我tm迟早得把InstFetch这坨屎给重写了!!!!!

module InstFetch(
    input               clk,
    input               rst,

    input               hold,    // 导致下一拍的pc不变

    input  wire         jmp_vld,
    input  wire [31:0]  jmp_addr,

    output reg  [31:0]  IF_pc,
    output wire [31:0]  IF_inst

);

reg     [31:0]  cnt;
reg     [`InstCatchDepth-3:0]  rdaddr, rdaddr_d1;
wire    [31:0]  rddata;

assign IF_inst = rddata;

always @(posedge clk) begin
    if (rst)
        cnt <= 'd4;
    else if (jmp_vld)
        cnt <= jmp_addr + 'd4;
    else if (hold)
        cnt <= cnt;
    else
        cnt <= cnt + 'd4;
end

always @(posedge clk) rdaddr_d1 <= rdaddr;

always @(*) begin
    if (jmp_vld)
        rdaddr = jmp_addr[`InstCatchDepth-1:2];
    else if (hold)
        rdaddr = rdaddr_d1;
    else
        rdaddr = cnt[`InstCatchDepth-1:2];
end

always @(posedge clk) begin
    if (rst)
        IF_pc <= 'd0;
    else if (jmp_vld)
        IF_pc <= jmp_addr;
    else if (hold)
        IF_pc <= IF_pc;
    else
        IF_pc <= cnt;
end

InstCatch u_InstCatch(
    .clk        ( clk    ),
    .addr       ( rdaddr ),
    .inst       ( rddata )
);

endmodule