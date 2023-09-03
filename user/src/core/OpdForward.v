// `include "../inc/defines.v"
`include "defines.v"

module OpdForward(
    /************************* rd *************************/
    // from EX
    input      [ 4:0]   EX_rd,
    input               EX_rd_vld,
    input      [31:0]   EX_x_rd,                // mabye not used
    // from MEM
    input      [ 4:0]   MEM_rd,
    input               MEM_rd_vld,
    input      [31:0]   MEM_x_rd,               // mabye not used
    // from ID_REG
    input      [ 4:0]   ID_REG_rs1, ID_REG_rs2,
    // from REGS
    input      [31:0]   REGS_rddata1, REGS_rddata2,
    // output
    output reg [31:0]   OF_x_rs1, OF_x_rs2,

    /************************ csr *************************/
    input      [11:0]   ID_REG_csr,
    input      [11:0]   EX_csr,
    input               EX_csr_vld,
    input      [31:0]   EX_x_csr,
    input      [31:0]   CSRs_rddata,
    output reg [31:0]   OF_x_csr
);

// OF_x_rs1
always @(*) begin
    if (EX_rd_vld && EX_rd == ID_REG_rs1 && EX_rd != 5'd0)
        OF_x_rs1 = EX_x_rd;
    else if (MEM_rd_vld && MEM_rd == ID_REG_rs1 && MEM_rd != 5'd0)
        OF_x_rs1 = MEM_x_rd;
    else
        OF_x_rs1 = REGS_rddata1;
end

// OF_x_rs2
always @(*) begin
    if (EX_rd_vld && EX_rd == ID_REG_rs2 && EX_rd != 5'd0)
        OF_x_rs2 = EX_x_rd;
    else if (MEM_rd_vld && MEM_rd == ID_REG_rs2 && MEM_rd != 5'd0)
        OF_x_rs2 = MEM_x_rd;
    else
        OF_x_rs2 = REGS_rddata2;
end

// OF_x_csr
always @(*) begin
    if (EX_csr_vld && EX_csr == ID_REG_csr)
        OF_x_csr = EX_x_csr;
    else
        OF_x_csr = CSRs_rddata;
end

endmodule