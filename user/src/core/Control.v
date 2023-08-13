module Control(
    // load-use型数据冒险
    input       [4:0]               ID_rs1, ID_rs2, 
    input       [4:0]               ID_rd_d1,
    input       [`InstIDDepth-1:0]  ID_instID_d1,
    output reg                      IF_hold, IF_nop,
    // jmp型数据冒险-无条件跳转
    input                           ID_jmp_vld,
    input       [31:0]              ID_imm,
    // jmp型数据冒险-条件跳转
    input                           EX_jmp_vld,
    input       [31:0]              EX_jmp_addr,
    // jmp型数据冒险-跳转信号的输出
    output reg                      IF_jmp_vld,
    output reg  [31:0]              IF_jmp_addr,
    // jmp型数据冒险-条件跳转 时 屏蔽下两条指令的执行
    output wire                     EX_inst_vld
);

reg EX_jmp_vld_d1;

// 第二条指令的某一个rs与第一条指令的rd相同, 且第一条指令是load类型
// 这叫load-use型数据冒险, 必须有一次硬件阻塞.
always @(*) begin
    IF_hold = 1'b0;
    IF_nop = 1'b0;
    if (ID_rs1 == ID_rd_d1 || ID_rs2 == ID_rd_d1) begin
        if (ID_instID_d1 == `ID_LW) begin
            IF_hold = 1'b1;
            IF_nop = 1'b1;
        end
    end
end

// 无条件跳转: 由于跳转的地址在IF2ID阶段就已经确定(我设计于ID的组合逻辑), 
// 所以通过设计旁路电路, 将计算结果更早地送入PC, 这种方法被称为缩短分支延迟
// 条件跳转: 正常跳转
// 优先级: 条件跳转 > 无条件跳转 > 无跳转
always @(*) begin
    if (EX_jmp_vld) begin
        IF_jmp_vld = 1'b1;
        IF_jmp_addr = ID_imm;
    end
    else if (ID_jmp_vld) begin
        IF_jmp_vld = 1'b1;
        IF_jmp_addr = EX_jmp_addr;
    end
    else begin
        IF_jmp_vld = 1'b0;
        IF_jmp_addr = 32'h0;
    end
end

// EX输出jmp_vld时, 说明当前拍和下一拍的指令都是无效指令, 所以有2拍的inst_vld为0
always @(posedge clk) EX_jmp_vld_d1 <= EX_jmp_vld;
assign EX_inst_vld = ~EX_jmp_vld & ~EX_jmp_vld_d1;


endmodule