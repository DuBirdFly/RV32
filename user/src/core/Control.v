`include "../inc/defines.v"

module Control(
    input                           clk,

    // load-use型数据冒险
    input       [4:0]               ID_rs1, ID_rs2,
    input                           ID_rs1_vld, ID_rs2_vld,
    input       [4:0]               ID_REG_rd,
    input       [6:0]               ID_REG_opcode,
    output wire                     hold_IF,
    // jmp型数据冒险-无条件跳转
    input                           ID_jmp_vld,
    input       [31:0]              ID_imm,
    input       [31:0]              ID_pc,
    // jmp型数据冒险-条件跳转
    input                           EX_jmp_vld,
    input       [31:0]              EX_jmp_addr,
    // jmp型数据冒险-跳转信号的输出
    output reg                      CTRL_IF_jmp_vld,
    output reg  [31:0]              CTRL_IF_jmp_addr,
    // 屏蔽下EX指令的执行
    output wire                     CTRL_EX_en
);

reg EX_jmp_vld_d1;
reg hold_IF_d1;

// 第二条指令的某一个rs与第一条指令的rd相同, 且第一条指令是load类型
// 这叫load-use型数据冒险, 必须有一次硬件阻塞.
always @(posedge clk) hold_IF_d1 = hold_IF;
assign hold_IF = ((ID_rs1 == ID_REG_rd && ID_rs1_vld) || (ID_rs2 == ID_REG_rd && ID_rs2_vld)) &&
                 (ID_REG_opcode == 7'b000_0011) &&
                 (~hold_IF_d1);
 
// 无条件跳转: 由于跳转的地址在IF2ID阶段就已经确定(我设计于ID的组合逻辑), 
// 所以通过设计旁路电路, 将计算结果更早地送入PC, 这种方法被称为缩短分支延迟
// 条件跳转: 正常跳转
// 优先级: 条件跳转 > 无条件跳转 > 无跳转
always @(*) begin
    if (EX_jmp_vld) begin
        CTRL_IF_jmp_vld = 1'b1;
        CTRL_IF_jmp_addr = EX_jmp_addr;
    end
    else if (ID_jmp_vld) begin
        CTRL_IF_jmp_vld = 1'b1;
        CTRL_IF_jmp_addr = ID_imm + ID_pc;
    end
    else begin
        CTRL_IF_jmp_vld = 1'b0;
        CTRL_IF_jmp_addr = 32'h0;
    end
end

// jmp to nop; 由于EX_jmp导致了2拍的nop
wire jmp2nop;
always @(posedge clk) EX_jmp_vld_d1 <= EX_jmp_vld;
assign jmp2nop = EX_jmp_vld | EX_jmp_vld_d1;

// hold to nop; 由于load-use型数据冒险导致了1拍的nop
reg hold2nop;
always @(posedge clk) hold2nop <= hold_IF;

assign CTRL_EX_en = ~(jmp2nop | hold2nop);

endmodule