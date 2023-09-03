// `include "../inc/defines.v"
`include "defines.v"
module Execute(
    input                               clk,
    input                               en,

    input       [`InstIDDepth-1:0]      instID,
    input       [4:0]                   rd,
    input       [31:0]                  x_rs1, x_rs2, imm, pc,
    input                               rd_vld,

    input       [11:0]                  csr,
    input                               csr_vld,
    input       [31:0]                  x_csr,

    // jump
    output reg                          EX_jmp_vld,
    output reg  [31:0]                  EX_jmp_addr,
    // x_rd
    output reg  [4:0]                   EX_rd,
    output reg                          EX_rd_vld,
    output reg  [31:0]                  EX_x_rd,
    // MEM
    output reg  [31:0]                  EX_MEM_addr,
    output reg  [3:0]                   EX_MEM_rden,
    output reg                          EX_MEM_rden_SEXT,// lb/lbu, lh/lhu, 区分是否需要符号拓展
    output reg  [3:0]                   EX_MEM_wren,
    output reg  [31:0]                  EX_MEM_wrdata,
    // CSRs
    output reg  [11:0]                  EX_csr,
    output reg                          EX_csr_vld,
    output reg  [31:0]                  EX_x_csr
);

wire [31:0] EX_MEM_addr_comb;
assign EX_MEM_addr_comb = x_rs1 + imm;

always @(posedge clk) begin
    EX_rd <= rd;
    EX_csr <= csr;
end

always @(posedge clk) begin
    if (en) begin
        EX_rd_vld <= rd_vld;
        EX_csr_vld <= csr_vld;
    end
    else begin
        EX_rd_vld <= 1'b0;
        EX_csr_vld <= 1'b0;
    end   
end

always @(posedge clk) begin
    // 控制信号的一般值 (经过我的测试,这种写法是支持的)
    EX_jmp_vld <= 1'b0;
    {EX_MEM_rden, EX_MEM_wren} <= 8'b0000_0000;
    EX_MEM_rden_SEXT <= 1'b0;
    // 控制信号与数据信号的特殊值
    if (en) begin
        case (instID)
            `ID_ADDI: EX_x_rd <= x_rs1 + imm;
            `ID_ANDI: EX_x_rd <= x_rs1 & imm;
            `ID_ORI: EX_x_rd <= x_rs1 | imm;
            `ID_XORI: EX_x_rd <= x_rs1 ^ imm;
            `ID_SLTI: EX_x_rd <= ($signed(x_rs1) < $signed(imm)) ? 32'd1 : 32'd0;
            `ID_SLTIU: EX_x_rd <= (x_rs1 < imm) ? 32'd1 : 32'd0;
            `ID_SLLI: EX_x_rd <= x_rs1 << imm[4:0];
            `ID_SRLI: EX_x_rd <= x_rs1 >> imm[4:0];
            `ID_SRAI: EX_x_rd <= $signed(x_rs1) >>> imm[4:0];
            `ID_ADD: EX_x_rd <= x_rs1 + x_rs2;
            `ID_AND: EX_x_rd <= x_rs1 & x_rs2;
            `ID_SUB: EX_x_rd <= x_rs1 - x_rs2;
            `ID_OR: EX_x_rd <= x_rs1 | x_rs2;
            `ID_XOR: EX_x_rd <= x_rs1 ^ x_rs2;
            `ID_SLL: EX_x_rd <= x_rs1 << (x_rs2[4:0]);
            `ID_SRL: EX_x_rd <= x_rs1 >> (x_rs2[4:0]);
            `ID_SRA: EX_x_rd <= $signed(x_rs1) >>> (x_rs2[4:0]);
            `ID_SLT: EX_x_rd <= ($signed(x_rs1) < $signed(x_rs2)) ? 32'd1 : 32'd0;
            `ID_SLTU: EX_x_rd <= (x_rs1 < x_rs2) ? 32'd1 : 32'd0;
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
                EX_x_rd <= pc + 'd4;
            end
            `ID_JALR: begin
                EX_jmp_vld <= 1'b1;
                EX_jmp_addr <= (x_rs1 + imm) & (~32'd1);
                EX_x_rd <= pc + 'd4;
            end
            `ID_LUI: begin
                EX_x_rd <= imm;
            end
            `ID_AUIPC: begin
                EX_x_rd <= pc + imm;
            end
            `ID_LW: begin
                {EX_MEM_rden, EX_MEM_wren} <= 8'b1111_0000;
                EX_MEM_addr <= EX_MEM_addr_comb;
            end
            `ID_LH: begin
                {EX_MEM_rden, EX_MEM_wren} <= EX_MEM_addr_comb[1] ? 8'b1100_0000 : 8'b0011_0000;
                EX_MEM_addr <= EX_MEM_addr_comb;
                EX_MEM_rden_SEXT <= 1'b1;
            end
            `ID_LHU: begin
                {EX_MEM_rden, EX_MEM_wren} <= EX_MEM_addr_comb[1] ? 8'b1100_0000 : 8'b0011_0000;
                EX_MEM_addr <= EX_MEM_addr_comb;
            end
            `ID_LB: begin
                case(EX_MEM_addr_comb[1:0])
                    3'b00: {EX_MEM_rden, EX_MEM_wren} <= 8'b0001_0000;
                    3'b01: {EX_MEM_rden, EX_MEM_wren} <= 8'b0010_0000;
                    3'b10: {EX_MEM_rden, EX_MEM_wren} <= 8'b0100_0000;
                    3'b11: {EX_MEM_rden, EX_MEM_wren} <= 8'b1000_0000;
                endcase
                EX_MEM_addr <= EX_MEM_addr_comb;
                EX_MEM_rden_SEXT <= 1'b1;
            end
            `ID_LBU: begin
                case(EX_MEM_addr_comb[1:0])
                    3'b00: {EX_MEM_rden, EX_MEM_wren} <= 8'b0001_0000;
                    3'b01: {EX_MEM_rden, EX_MEM_wren} <= 8'b0010_0000;
                    3'b10: {EX_MEM_rden, EX_MEM_wren} <= 8'b0100_0000;
                    3'b11: {EX_MEM_rden, EX_MEM_wren} <= 8'b1000_0000;
                endcase
                EX_MEM_addr <= EX_MEM_addr_comb;
            end
            `ID_SW: begin
                {EX_MEM_rden, EX_MEM_wren} <= 8'b0000_1111;
                EX_MEM_addr <= EX_MEM_addr_comb;
                EX_MEM_wrdata <= x_rs2;
            end
            `ID_SB: begin
                case(EX_MEM_addr_comb[1:0])
                    3'b00: {EX_MEM_rden, EX_MEM_wren} <= 8'b0000_0001;
                    3'b01: {EX_MEM_rden, EX_MEM_wren} <= 8'b0000_0010;
                    3'b10: {EX_MEM_rden, EX_MEM_wren} <= 8'b0000_0100;
                    3'b11: {EX_MEM_rden, EX_MEM_wren} <= 8'b0000_1000;
                endcase
                EX_MEM_addr <= EX_MEM_addr_comb;
                EX_MEM_wrdata <= {4{x_rs2[7:0]}};
            end
            `ID_SH: begin
                {EX_MEM_rden, EX_MEM_wren} <= EX_MEM_addr_comb[1] ? 8'b0000_1100 : 8'b0000_0011;
                EX_MEM_addr <= EX_MEM_addr_comb;
                EX_MEM_wrdata <= {2{x_rs2[15:0]}};
            end
            `ID_CSRRW: begin
                EX_x_rd <= x_csr;
                EX_x_csr <= x_rs1;
            end
            `ID_CSRRS: begin
                EX_x_rd <= x_csr;
                EX_x_csr <= x_csr | x_rs1;
            end
            `ID_CSRRC: begin
                EX_x_rd <= x_csr;
                EX_x_csr <= x_csr & (~x_rs1);
            end
            `ID_CSRRWI: begin
                EX_x_rd <= x_csr;
                EX_x_csr <= imm;
            end
            `ID_CSRRSI: begin
                EX_x_rd <= x_csr;
                EX_x_csr <= x_csr | imm;
            end
            `ID_CSRRCI: begin
                EX_x_rd <= x_csr;
                EX_x_csr <= x_csr & (~imm);
            end
        endcase
    end
end

endmodule