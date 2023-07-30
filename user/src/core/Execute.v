`include "defines.v"

module Execute(
    input                               clk,

    input       [31:0]                  x_rs1, x_rs2, 
    input       [31:0]                  imm,
    input       [`InstIDDepth-1:0]      instID,
    input       [31:0]                  pc,

    // jump
    output reg                          EX_jump_flag,
    output reg  [31:0]                  EX_jump_addr,
    // x_rd
    output reg  [31:0]                  EX_x_rd,        // create by ALU
    // x_rd or MEM
    output reg                          EX_x_rd_vld,    // create by ALU or MEM
    // MEM
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
            EX_jump_flag <= 1'b0;
            EX_x_rd_vld <= 1'b1;
            {MEMrden, MEMwren} <= 8'b0000_0000;
            // data
            EX_x_rd <= x_rs1 + imm;
        end
        `ID_ADD: begin
            // ctrl
            EX_jump_flag <= 1'b0;
            EX_x_rd_vld <= 1'b1;
            {MEMrden, MEMwren} <= 8'b0000_0000;
            // data
            EX_x_rd <= x_rs1 + x_rs2;
        end
        `ID_LUI: begin
            // ctrl
            EX_jump_flag <= 1'b0;
            EX_x_rd_vld <= 1'b1;
            {MEMrden, MEMwren} <= 8'b0000_0000;
            // data
            EX_x_rd <= imm;
        end
        `ID_BNE: begin
            // ctrl
            EX_jump_flag <= (x_rs1 != x_rs2);
            EX_x_rd_vld <= 1'b0;
            {MEMrden, MEMwren} <= 8'b0000_0000;
            // data
            EX_jump_addr <= pc + imm;
        end
        `ID_JAL: begin
            // ctrl
            EX_jump_flag <= 1'b1;
            EX_x_rd_vld <= 1'b1;
            {MEMrden, MEMwren} <= 8'b0000_0000;
            // data
            EX_jump_addr <= pc + imm;
            EX_x_rd <= pc + 'd4;
        end
        `ID_LW: begin
            // ctrl
            EX_jump_flag <= 1'b0;
            EX_x_rd_vld <= 1'b1;
            {MEMrden, MEMwren} <= 8'b1111_0000;
            // data
            MEMaddr <= x_rs1 + imm;
        end
        `ID_SW: begin
            // ctrl
            EX_jump_flag <= 1'b0;
            EX_x_rd_vld <= 1'b0;
            {MEMrden, MEMwren} <= 8'b0000_1111;
            // data
            MEMaddr <= x_rs1 + imm;
            MEMwrdata <= x_rs2;
        end
        default: error <= 1'b1;
    endcase
end

endmodule