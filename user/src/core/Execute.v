`include "defines.v"

module Execute(
    input                               clk,

    input       [31:0]                  x_rs1, x_rs2, 
    input       [31:0]                  imm,
    input       [`InstIDDepth-1:0]      instID,
    input       [31:0]                  pc,

    // jump
    output reg                          EX_jmp_vld,
    output reg  [31:0]                  EX_jmp_addr,
    // x_rd
    output reg  [31:0]                  EX_x_rd,        // create by ALU
    // x_rd or MEM
    output reg                          EX_x_rd_vld,    // create by ALU or MEM
    // MEM
    output reg  [31:0]                  EX_MEMaddr,
    output reg  [3:0]                   EX_MEMrden,
    output reg  [3:0]                   EX_MEMwren,
    output reg  [31:0]                  EX_MEMwrdata,

    output reg                          error
);

always @(posedge clk) begin
    case (instID)
        `ID_ADDI: begin
            // ctrl
            EX_jmp_vld <= 1'b0;
            EX_x_rd_vld <= 1'b1;
            {EX_MEMrden, EX_MEMwren} <= 8'b0000_0000;
            // data
            EX_x_rd <= x_rs1 + imm;
        end
        `ID_ADD: begin
            // ctrl
            EX_jmp_vld <= 1'b0;
            EX_x_rd_vld <= 1'b1;
            {EX_MEMrden, EX_MEMwren} <= 8'b0000_0000;
            // data
            EX_x_rd <= x_rs1 + x_rs2;
        end
        `ID_LUI: begin
            // ctrl
            EX_jmp_vld <= 1'b0;
            EX_x_rd_vld <= 1'b1;
            {EX_MEMrden, EX_MEMwren} <= 8'b0000_0000;
            // data
            EX_x_rd <= imm;
        end
        `ID_BNE: begin
            // ctrl
            EX_jmp_vld <= (x_rs1 != x_rs2);
            EX_x_rd_vld <= 1'b0;
            {EX_MEMrden, EX_MEMwren} <= 8'b0000_0000;
            // data
            EX_jmp_addr <= pc + imm;
        end
        `ID_JAL: begin
            // ctrl
            EX_jmp_vld <= 1'b1;
            EX_x_rd_vld <= 1'b1;
            {EX_MEMrden, EX_MEMwren} <= 8'b0000_0000;
            // data
            EX_jmp_addr <= pc + imm;
            EX_x_rd <= pc + 'd4;
        end
        `ID_LW: begin
            // ctrl
            EX_jmp_vld <= 1'b0;
            // 虽然说确实x_rd_vld, 但是这个vld不是EX造成的
            EX_x_rd_vld <= 1'b0;
            {EX_MEMrden, EX_MEMwren} <= 8'b1111_0000;
            // data
            EX_MEMaddr <= x_rs1 + imm;
        end
        `ID_SW: begin
            // ctrl
            EX_jmp_vld <= 1'b0;
            EX_x_rd_vld <= 1'b0;
            {EX_MEMrden, EX_MEMwren} <= 8'b0000_1111;
            // data
            EX_MEMaddr <= x_rs1 + imm;
            EX_MEMwrdata <= x_rs2;
        end
        default: error <= 1'b1;
    endcase
end

endmodule