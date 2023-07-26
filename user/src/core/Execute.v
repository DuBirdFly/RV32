`include "defines.v"

module Excute(
    input                               clk,

    input       [31:0]                  x_rs1, x_rs2, 
    input       [31:0]                  imm,
    input       [`InstIDDepth-1:0]      instID,
    input       [31:0]                  pc,

    // jump
    output reg                          jump_flag,
    output reg  [31:0]                  jump_addr,
    // x_rd could be create by ALU or MEM
    output reg  [31:0]                  x_rd,
    output reg                          x_rd_vld,       // x_rd_valid
    output reg  [31:0]                  MEMaddr,
    output reg  [3:0]                   MEMrden,
    output reg  [3:0]                   MEMwren,
    output reg  [31:0]                  MEMwrdata,

    output reg                          error
);

always @(posedge clk) begin
    case (instID)
        `ID_ADDI: begin
            // ctrl
            jump_flag <= 1'b0;
            x_rd_vld <= 1'b1;
            {MEMrden, MEMwren} <= 8'b0000_0000;
            // data
            x_rd <= x_rs1 + imm;
        end
        `ID_ADD: begin
            // ctrl
            jump_flag <= 1'b0;
            x_rd_vld <= 1'b1;
            {MEMrden, MEMwren} <= 8'b0000_0000;
            // data
            x_rd <= x_rs1 + x_rs2;
        end
        `ID_LUI: begin
            // ctrl
            jump_flag <= 1'b0;
            x_rd_vld <= 1'b1;
            {MEMrden, MEMwren} <= 8'b0000_0000;
            // data
            x_rd <= imm;
        end
        `ID_BNE: begin
            // ctrl
            jump_flag <= (x_rs1 != x_rs2);
            x_rd_vld <= 1'b0;
            {MEMrden, MEMwren} <= 8'b0000_0000;
            // data
            jump_addr <= pc + imm;
        end
        `ID_JAL: begin
            // ctrl
            jump_flag <= 1'b1;
            x_rd_vld <= 1'b1;
            {MEMrden, MEMwren} <= 8'b0000_0000;
            // data
            jump_addr <= pc + imm;
            x_rd <= pc + 'd4;
        end
        `ID_LW: begin
            // ctrl
            jump_flag <= 1'b0;
            x_rd_vld <= 1'b1;
            {MEMrden, MEMwren} <= 8'b1111_0000;
            // data
            MEMaddr <= x_rs1 + imm;
        end
        `ID_SW: begin
            // ctrl
            jump_flag <= 1'b0;
            x_rd_vld <= 1'b0;
            {MEMrden, MEMwren} <= 8'b0000_1111;
            // data
            MEMaddr <= x_rs1 + imm;
        end
        default: error <= 1'b1;
    endcase
end

endmodule