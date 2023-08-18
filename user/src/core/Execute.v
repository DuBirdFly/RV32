// `include "../inc/defines.v"
`include "defines.v"
module Execute(
    input                               clk,
    input                               inst_vld,

    input       [31:0]                  x_rs1, x_rs2, 
    input       [31:0]                  imm,
    input       [`InstIDDepth-1:0]      instID,
    input       [31:0]                  pc,

    // jump
    output reg                          EX_jmp_vld,
    output reg  [31:0]                  EX_jmp_addr,
    // x_rd
    output reg                          EX_x_rd_vld,    // create by ALU or MEM
    output reg  [31:0]                  EX_x_rd,        // create by ALU
    // MEM
    output reg  [31:0]                  EX_MEMaddr,
    output reg  [3:0]                   EX_MEMrden,
    output reg  [3:0]                   EX_MEMwren,
    output reg  [31:0]                  EX_MEMwrdata
);

always @(posedge clk) begin
    // 控制信号的一般值 (经过我的测试,这种写法是支持的)
    EX_jmp_vld <= 1'b0;
    EX_x_rd_vld <= 1'b0;
    {EX_MEMrden, EX_MEMwren} <= 8'b0000_0000;
    // 控制信号与数据信号的特殊值
    if (inst_vld) begin
        case (instID)
            `ID_ADDI: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= x_rs1 + imm;
            end
            `ID_ADD: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= x_rs1 + x_rs2;
            end
            `ID_ANDI: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= x_rs1 & imm;
            end
            `ID_AND: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= x_rs1 & x_rs2;
            end
            `ID_SUB: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= x_rs1 - x_rs2;
            end
            `ID_BNE: begin
                EX_jmp_vld <= (x_rs1 != x_rs2);
                EX_jmp_addr <= pc + imm;
            end
            `ID_BEQ: begin
                EX_jmp_vld <= (x_rs1 == x_rs2);
                EX_jmp_addr <= pc + imm;
            end
            `ID_BGE: begin
                EX_jmp_vld <= ($signed(x_rs1) >= $signed(x_rs2));
                EX_jmp_addr <= pc + imm;
            end
            `ID_BGEU: begin
                EX_jmp_vld <= (x_rs1 >= x_rs2);
                EX_jmp_addr <= pc + imm;
            end
            `ID_BLT: begin
                EX_jmp_vld <= ($signed(x_rs1) < $signed(x_rs2));
                EX_jmp_addr <= pc + imm;
            end
            `ID_BLTU: begin
                EX_jmp_vld <= (x_rs1 < x_rs2);
                EX_jmp_addr <= pc + imm;
            end
            `ID_JAL: begin
                // 无条件跳转早在IF2ID阶段就已经确定, 所以无需EX_jmp_vld
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= pc + 'd4;
            end
            `ID_JALR: begin
                EX_jmp_vld <= 1'b1;
                EX_jmp_addr <= (x_rs1 + imm) & (~32'd1);
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= pc + 'd4;
            end
            `ID_LUI: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= imm;
            end
            `ID_AUIPC: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= pc + imm;
            end
            `ID_LW: begin
                // 虽然说确实 x_rd_vld, 但是这个vld不是EX造成的, 留给MEM阶段拉高EX_x_rd_vld
                {EX_MEMrden, EX_MEMwren} <= 8'b1111_0000;
                EX_MEMaddr <= x_rs1 + imm;
            end
            `ID_SW: begin
                {EX_MEMrden, EX_MEMwren} <= 8'b0000_1111;
                EX_MEMaddr <= x_rs1 + imm;
                EX_MEMwrdata <= x_rs2;
            end
        endcase
    end
end

endmodule