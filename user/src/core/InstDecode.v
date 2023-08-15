// `include "../inc/defines.v"
`include "defines.v"

module InstructionDecode(
    input                           clk,
    
    input       [31:0]              inst,                   // from IF

    // 正常输出
    output wire [4:0]               ID_rs1, ID_rs2, ID_rd,  // 读32位寄存器地址1, 2; 写32位寄存器地址
    output reg  [31:0]              ID_imm,                 // 32位的立即数 (大概率要符号拓展)
    output reg  [`InstIDDepth-1:0]  ID_instID,              // define的instID, 如: ID_ADDI=8'd2; ID_BNE=8'd33

    // 控制冒险: 无条件跳转 (只有 OPCODE_J_JAL 才会触发， 立即反馈到 IF， 此时的jmp_addr = imm)
    output wire                     ID_jmp_vld               // 生成跳转信号, to IF
);

// rs1, rs2, rd 都是固定位置的
assign ID_rs1 = inst[19:15];
assign ID_rs2 = inst[24:20];
assign ID_rd = inst[11:7];

// 处理无条件跳转型数据冒险: 立即反馈到 IF， 执行跳转
assign ID_jmp_vld = (inst[6:0] == `OPCODE_J_JAL);

// 转为组合逻辑
always @(*) begin
    ID_imm = 32'b0;
    ID_instID = 'd0;

    case (inst[6:0])
        `OPCODE_I_COMPU:
            case (inst[14:12])
                `FUNCT3_ADDI: begin
                    ID_imm = { {20{inst[31]}}, inst[31:20] };     // 符号扩展
                    ID_instID = `ID_ADDI;
                end
            endcase

        `OPCODE_R:
            case (inst[14:12])
                `FUNCT3_ADD: begin
                    ID_instID = `ID_ADD;
                end
            endcase

        `OPCODE_U_LUI: begin
            ID_imm = {  inst[31:12] , 12'd0 }; 
            ID_instID = `ID_LUI;
        end

        `OPCODE_B:
            case (inst[14:12])
                `FUNCT3_BNE: begin
                    ID_imm = { {19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0 };
                    ID_instID = `ID_BNE;
                end
            endcase

        `OPCODE_J_JAL: begin
            ID_imm = { {12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0 };
            ID_instID = `ID_JAL;
        end

        `OPCODE_I_LW:
            case (inst[14:12])
                `FUNCT3_LW: begin
                    ID_imm = { {20{inst[31]}}, inst[31:20] };
                    ID_instID = `ID_LW;
                end
            endcase

        `OPCODE_I_SW:
            case (inst[14:12])
                `FUNCT3_SW: begin
                    ID_imm = { {20{inst[31]}}, inst[31:25], inst[11:7] };
                    ID_instID = `ID_SW;
                end
            endcase

    endcase
end

endmodule