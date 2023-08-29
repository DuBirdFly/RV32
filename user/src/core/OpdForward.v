// `include "../inc/defines.v"
`include "defines.v"

module OpdForward(
    // from EX
    input      [ 4:0]   EX_rd,
    input               EX_rd_vld,
    input      [31:0]   EX_x_rd,                // mabye not used
    // from REGS
    input      [ 4:0]   ID_REG_rs1, ID_REG_rs2,
    input      [31:0]   REGS_rddata1, REGS_rddata2,
    // output
    output reg [31:0]   OF_x_rs1, OF_x_rs2
);

// OF_x_rs1
always @(*) begin
    if (EX_rd_vld && EX_rd == ID_REG_rs1 && EX_rd != 5'd0)
        OF_x_rs1 = EX_x_rd;
    else
        OF_x_rs1 = REGS_rddata1;
end

// OF_x_rs2
always @(*) begin
    if (EX_rd_vld && EX_rd == ID_REG_rs2 && EX_rd != 5'd0)
        OF_x_rs2 = EX_x_rd;
    else
        OF_x_rs2 = REGS_rddata2;
end


endmodule