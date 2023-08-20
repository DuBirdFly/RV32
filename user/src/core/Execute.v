// `include "../inc/defines.v"
`include "defines.v"
module Execute(
    input                               clk,
    input                               inst_vld,

    input       [4:0]                   rd,
    input       [31:0]                  x_rs1, x_rs2, 
    input       [31:0]                  imm,
    input       [`InstIDDepth-1:0]      instID,
    input       [31:0]                  pc,

    // jump
    output reg                          EX_jmp_vld,
    output reg  [31:0]                  EX_jmp_addr,
    // x_rd
    output reg                          EX_x_rd_vld,
    output reg  [31:0]                  EX_x_rd,        // create by ALU
    output reg  [4:0]                   EX_rd,
    // MEM
    output reg  [31:0]                  EX_MEMaddr,
    output reg  [3:0]                   EX_MEMrden,
    output reg                          EX_MEMrden_SEXT,// lb/lbu, lh/lhu, 区分是否需要符号拓展
    output reg  [3:0]                   EX_MEMwren,
    output reg  [31:0]                  EX_MEMwrdata

);

wire [31:0] EX_MEMaddr_comb;
assign EX_MEMaddr_comb = x_rs1 + imm;

always @(posedge clk) EX_rd <= rd;

always @(posedge clk) begin
    // 控制信号的一般值 (经过我的测试,这种写法是支持的)
    EX_x_rd_vld <= 1'b0;
    EX_jmp_vld <= 1'b0;
    {EX_MEMrden, EX_MEMwren} <= 8'b0000_0000;
    EX_MEMrden_SEXT <= 1'b0;
    // 控制信号与数据信号的特殊值
    if (inst_vld) begin
        case (instID)
            `ID_ADDI: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= x_rs1 + imm;
            end
            `ID_ANDI: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= x_rs1 & imm;
            end
            `ID_ORI: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= x_rs1 | imm;
            end
            `ID_XORI: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= x_rs1 ^ imm;
            end
            `ID_SLTI: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= ($signed(x_rs1) < $signed(imm)) ? 32'd1 : 32'd0;
            end
            `ID_SLTIU: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= (x_rs1 < imm) ? 32'd1 : 32'd0;
            end
            `ID_SLLI: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= x_rs1 << imm[4:0];
            end
            `ID_SRLI: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= x_rs1 >> imm[4:0];
            end
            `ID_SRAI: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= $signed(x_rs1) >>> imm[4:0];
            end
            `ID_ADD: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= x_rs1 + x_rs2;
            end
            `ID_AND: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= x_rs1 & x_rs2;
            end
            `ID_SUB: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= x_rs1 - x_rs2;
            end
            `ID_OR: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= x_rs1 | x_rs2;
            end
            `ID_XOR: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= x_rs1 ^ x_rs2;
            end
            `ID_SLL: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= x_rs1 << (x_rs2[4:0]);
            end
            `ID_SRL: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= x_rs1 >> (x_rs2[4:0]);
            end
            `ID_SRA: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= $signed(x_rs1) >>> (x_rs2[4:0]);
            end
            `ID_SLT: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= ($signed(x_rs1) < $signed(x_rs2)) ? 32'd1 : 32'd0;
            end
            `ID_SLTU: begin
                EX_x_rd_vld <= 1'b1;
                EX_x_rd <= (x_rs1 < x_rs2) ? 32'd1 : 32'd0;
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
                EX_x_rd_vld <= 1'b1;
                {EX_MEMrden, EX_MEMwren} <= 8'b1111_0000;
                EX_MEMaddr <= EX_MEMaddr_comb;
            end
            `ID_LH: begin
                EX_x_rd_vld <= 1'b1;
                {EX_MEMrden, EX_MEMwren} <= EX_MEMaddr_comb[1] ? 8'b1100_0000 : 8'b0011_0000;
                EX_MEMaddr <= EX_MEMaddr_comb;
                EX_MEMrden_SEXT <= 1'b1;
            end
            `ID_LHU: begin
                EX_x_rd_vld <= 1'b1;
                {EX_MEMrden, EX_MEMwren} <= EX_MEMaddr_comb[1] ? 8'b1100_0000 : 8'b0011_0000;
                EX_MEMaddr <= EX_MEMaddr_comb;
                EX_MEMrden_SEXT <= 1'b0;
            end
            `ID_LB: begin
                EX_x_rd_vld <= 1'b1;
                case(EX_MEMaddr_comb[1:0])
                    3'b00: {EX_MEMrden, EX_MEMwren} <= 8'b0001_0000;
                    3'b01: {EX_MEMrden, EX_MEMwren} <= 8'b0010_0000;
                    3'b10: {EX_MEMrden, EX_MEMwren} <= 8'b0100_0000;
                    3'b11: {EX_MEMrden, EX_MEMwren} <= 8'b1000_0000;
                endcase
                EX_MEMaddr <= EX_MEMaddr_comb;
                EX_MEMrden_SEXT <= 1'b1;
            end
            `ID_LBU: begin
                EX_x_rd_vld <= 1'b1;
                case(EX_MEMaddr_comb[1:0])
                    3'b00: {EX_MEMrden, EX_MEMwren} <= 8'b0001_0000;
                    3'b01: {EX_MEMrden, EX_MEMwren} <= 8'b0010_0000;
                    3'b10: {EX_MEMrden, EX_MEMwren} <= 8'b0100_0000;
                    3'b11: {EX_MEMrden, EX_MEMwren} <= 8'b1000_0000;
                endcase
                EX_MEMaddr <= EX_MEMaddr_comb;
                EX_MEMrden_SEXT <= 1'b0;
            end
            `ID_SW: begin
                {EX_MEMrden, EX_MEMwren} <= 8'b0000_1111;
                EX_MEMaddr <= EX_MEMaddr_comb;
                EX_MEMwrdata <= x_rs2;
            end
            `ID_SB: begin
                case(EX_MEMaddr_comb[1:0])
                    3'b00: {EX_MEMrden, EX_MEMwren} <= 8'b0000_0001;
                    3'b01: {EX_MEMrden, EX_MEMwren} <= 8'b0000_0010;
                    3'b10: {EX_MEMrden, EX_MEMwren} <= 8'b0000_0100;
                    3'b11: {EX_MEMrden, EX_MEMwren} <= 8'b0000_1000;
                endcase
                EX_MEMaddr <= EX_MEMaddr_comb;
                EX_MEMwrdata <= {4{x_rs2[7:0]}};
            end
            `ID_SH: begin
                {EX_MEMrden, EX_MEMwren} <= EX_MEMaddr_comb[1] ? 8'b0000_1100 : 8'b0000_0011;
                EX_MEMaddr <= EX_MEMaddr_comb;
                EX_MEMwrdata <= {2{x_rs2[15:0]}};
            end
        endcase
    end
end

endmodule