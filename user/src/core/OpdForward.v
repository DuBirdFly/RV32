// `include "../inc/defines.v"
`include "defines.v"

module OpdForward(
    // from EX
    input      [ 4:0]   EX_rd,
    input      [31:0]   EX_x_rd,                // mabye not used
    input               EX_x_rd_vld,
    // from REGS
    input      [ 4:0]   REGS_rdaddr1, REGS_rdaddr2,
    input      [31:0]   REGS_rddata1, REGS_rddata2,
    // output
    output reg [31:0]   OF_x_rs1, OF_x_rs2
);

always @(*) begin
    if (EX_x_rd_vld && EX_rd == REGS_rdaddr1) begin
        OF_x_rs1 = EX_x_rd;
        OF_x_rs2 = REGS_rddata2;
    end
    else if (EX_x_rd_vld && EX_rd == REGS_rdaddr2) begin
        OF_x_rs1 = REGS_rddata1;
        OF_x_rs2 = EX_x_rd;
    end
    else begin
        OF_x_rs1 = REGS_rddata1;
        OF_x_rs2 = REGS_rddata2;
    end
end

endmodule