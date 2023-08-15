// `include "../inc/defines.v"
`include "defines.v"

module Registers (
    input               clk,
    // read
    input       [ 4:0]  REGS_rdaddr1,
    output reg  [31:0]  REGS_rddata1,
    input       [ 4:0]  REGS_rdaddr2,
    output reg  [31:0]  REGS_rddata2,
    // write
    input               REGS_wen,        // 写使能信号
    input       [ 4:0]  REGS_wraddr,
    input       [31:0]  REGS_wrdata
);

/*
FROM IVERILOG:
    $readmemh: The behaviour for reg[...] mem[N:0]; $readmemh("...", mem);
    changed in the 1364-2005 standard. 
    To avoid ambiguity, use mem[0:N] or $readmemh("...", mem, start, stop);
    Defaulting to 1364-2005 behavior.
*/
reg [31:0] regfile [0:31]; // 32个32位寄存器

// ug949: xilinx-ram上电初值为0
integer i;
initial begin
    for (i=0; i< 31 ; i=i+1) regfile[i] = 'd0;
end

// 同步写
always @(posedge clk) begin
    if (REGS_wen && REGS_wraddr != 0 )                // 0号寄存器不可写, hold状态不可写
        regfile[REGS_wraddr] <= REGS_wrdata;          
end

// 异步读
always @(*) begin
    if (REGS_rdaddr1 == REGS_wraddr && REGS_wen)
        REGS_rddata1 = REGS_wrdata;
    else
        REGS_rddata1 = regfile[REGS_rdaddr1];
end

// 异步读
always @(*) begin
    if (REGS_rdaddr2 == REGS_wraddr && REGS_wen)
        REGS_rddata2 = REGS_wrdata;
    else 
        REGS_rddata2 = regfile[REGS_rdaddr2];
end

endmodule