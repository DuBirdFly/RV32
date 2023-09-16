`include "../inc/defines.v"

module OpdForward(
    /************************* rd *************************/
    // from EX
    input      [ 4:0]   EX_rd,
    input      [31:0]   EX_x_rd,
    input               EX_rd_vld,
    input      [11:0]   EX_csr,
    input      [31:0]   EX_x_csr,
    input               EX_csr_vld,
    // from MEM
    input      [ 4:0]   MEM_rd,
    input      [31:0]   MEM_x_rd,
    input               MEM_rd_vld,
    // from ID_REG
    input      [ 4:0]   ID_REG_rs1, ID_REG_rs2,
    input      [11:0]   ID_REG_csr,
    // from REGS / CSRs
    input      [31:0]   REGs_rddata1, REGs_rddata2,
    input      [31:0]   CSRs_rddata,
    // output
    output reg [31:0]   OF_x_rs1, OF_x_rs2, OF_x_csr
);

// OF_x_rs1
always @(*) begin
    if (EX_rd_vld && EX_rd == ID_REG_rs1 && EX_rd != 5'd0)
        OF_x_rs1 = EX_x_rd;
    else if (MEM_rd_vld && MEM_rd == ID_REG_rs1 && MEM_rd != 5'd0)
        OF_x_rs1 = MEM_x_rd;
    else
        OF_x_rs1 = REGs_rddata1;
end

// OF_x_rs2
always @(*) begin
    if (EX_rd_vld && EX_rd == ID_REG_rs2 && EX_rd != 5'd0)
        OF_x_rs2 = EX_x_rd;
    else if (MEM_rd_vld && MEM_rd == ID_REG_rs2 && MEM_rd != 5'd0)
        OF_x_rs2 = MEM_x_rd;
    else
        OF_x_rs2 = REGs_rddata2;
end

// OF_x_csr
always @(*) begin
    if (EX_csr_vld && EX_csr == ID_REG_csr)
        OF_x_csr = EX_x_csr;
    else
        OF_x_csr = CSRs_rddata;
end

endmodule