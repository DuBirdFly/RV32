// `include "../inc/defines.v"
`include "defines.v"

// 给组合逻辑输出的译码结果进行1拍寄存器的存储

module InstDecodeReg(
    input                           clk,
    // from InstFetch, to Execute
    input  wire [31:0]              pc,
    output reg  [31:0]              ID_REG_pc,
    // input from InstDecode
    input       [6:0]               opcode,
    input       [4:0]               rs1, rs2, rd,
    input                           rd_vld,
    input       [31:0]              imm,
    input       [`InstIDDepth-1:0]  instID,
    // output to Execute
    output reg  [6:0]               ID_REG_opcode,
    output reg  [4:0]               ID_REG_rs1, ID_REG_rs2, ID_REG_rd,
    output reg                      ID_REG_rd_vld,
    output reg  [31:0]              ID_REG_imm,
    output reg  [`InstIDDepth-1:0]  ID_REG_instID
);

always @(posedge clk) begin
    ID_REG_pc           <= pc;
    ID_REG_opcode       <= opcode;
    ID_REG_rs1          <= rs1;
    ID_REG_rs2          <= rs2;
    ID_REG_rd           <= rd;
    ID_REG_rd_vld       <= rd_vld;
    ID_REG_imm          <= imm;
    ID_REG_instID       <= instID;
end

endmodule