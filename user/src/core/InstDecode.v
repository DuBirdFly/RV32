// `include "../inc/defines.v"
`include "defines.v"

module InstDecode(
    input       [31:0]              inst,                   // from IF
    // 正常输出
    output wire [6:0]               ID_opcode,
    output wire [4:0]               ID_rs1, ID_rs2, ID_rd,  // 读32位寄存器地址1, 2; 写32位寄存器地址
    output reg                      ID_rs1_vld, ID_rs2_vld, ID_rd_vld,
    output reg  [31:0]              ID_imm,                 // 32位的立即数 (大概率要符号拓展)
    output reg  [`InstIDDepth-1:0]  ID_instID,              // define的instID, 如: ID_ADDI=8'd2; ID_BNE=8'd33

    // 控制冒险: 无条件跳转 (只有 OPCODE_J_JAL 才会触发， 立即反馈到 IF， 此时的jmp_addr = imm)
    output wire                     ID_jmp_vld              // 生成跳转信号, to IF
);

// rs1, rs2, rd, opcode 都是固定位置的
assign ID_rs2 = inst[24:20];
assign ID_rs1 = inst[19:15];
assign ID_rd = inst[11:7];
assign ID_opcode = inst[6:0];

// 处理无条件跳转型数据冒险: 立即反馈到 IF， 执行跳转
assign ID_jmp_vld = (ID_opcode == `OPCODE_J_JAL);

// 转为组合逻辑
always @(*) begin
    ID_imm = 32'b0;
    ID_instID = 'd0;

    case (ID_opcode)
        `OPCODE_I_COMPU:begin
            {ID_rs1_vld, ID_rs2_vld, ID_rd_vld} = 3'b101;
            ID_imm = { {20{inst[31]}}, inst[31:20] };
            case (inst[14:12])
                `FUNCT3_ADDI: ID_instID = `ID_ADDI;
                `FUNCT3_ANDI: ID_instID = `ID_ANDI;
                `FUNCT3_ORI:  ID_instID = `ID_ORI;
                `FUNCT3_XORI: ID_instID = `ID_XORI;
                `FUNCT3_SLTI: ID_instID = `ID_SLTI;
                `FUNCT3_SLTIU:ID_instID = `ID_SLTIU;
                `FUNCT3_SLLI: ID_instID = `ID_SLLI;
                `FUNCT3_SRLI: ID_instID = inst[30] ? `ID_SRAI : `ID_SRLI;
            endcase
        end

        `OPCODE_R: begin
            {ID_rs1_vld, ID_rs2_vld, ID_rd_vld} = 3'b111;
            case (inst[14:12])
                `FUNCT3_ADD: ID_instID = inst[30] ? `ID_SUB : `ID_ADD;
                `FUNCT3_AND: ID_instID = `ID_AND;
                `FUNCT3_OR:  ID_instID = `ID_OR;
                `FUNCT3_XOR: ID_instID = `ID_XOR;
                `FUNCT3_SLL: ID_instID = `ID_SLL;
                `FUNCT3_SRL: ID_instID = inst[30] ? `ID_SRA : `ID_SRL;
                `FUNCT3_SLT: ID_instID = `ID_SLT;
                `FUNCT3_SLTU:ID_instID = `ID_SLTU;
            endcase
        end

        `OPCODE_U_LUI: begin
            {ID_rs1_vld, ID_rs2_vld, ID_rd_vld} = 3'b001;
            ID_imm = {  inst[31:12] , 12'd0 }; 
            ID_instID = `ID_LUI;
        end

        `OPCODE_U_AUIPC: begin
            {ID_rs1_vld, ID_rs2_vld, ID_rd_vld} = 3'b001;
            ID_imm = {  inst[31:12] , 12'd0 }; 
            ID_instID = `ID_AUIPC;
        end

        `OPCODE_B: begin
            {ID_rs1_vld, ID_rs2_vld, ID_rd_vld} = 3'b110;
            ID_imm = { {19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0 };
            case (inst[14:12])
                `FUNCT3_BNE:  ID_instID = `ID_BNE;
                `FUNCT3_BEQ:  ID_instID = `ID_BEQ;
                `FUNCT3_BGE:  ID_instID = `ID_BGE;
                `FUNCT3_BGEU: ID_instID = `ID_BGEU;
                `FUNCT3_BLT:  ID_instID = `ID_BLT;
                `FUNCT3_BLTU: ID_instID = `ID_BLTU;
            endcase
        end

        `OPCODE_J_JAL: begin
            {ID_rs1_vld, ID_rs2_vld, ID_rd_vld} = 3'b001;
            ID_imm = { {12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0 };
            ID_instID = `ID_JAL;
        end

        `OPCODE_J_JALR: begin
            {ID_rs1_vld, ID_rs2_vld, ID_rd_vld} = 3'b101;
            ID_imm = { {20{inst[31]}}, inst[31:20] };
            ID_instID = `ID_JALR;
        end

        `OPCODE_I_LOAD: begin
            {ID_rs1_vld, ID_rs2_vld, ID_rd_vld} = 3'b101;
            ID_imm = { {20{inst[31]}}, inst[31:20] };
            case (inst[14:12])
                `FUNCT3_LW: ID_instID = `ID_LW;
                `FUNCT3_LH: ID_instID = `ID_LH;
                `FUNCT3_LB: ID_instID = `ID_LB;
                `FUNCT3_LHU: ID_instID = `ID_LHU;
                `FUNCT3_LBU: ID_instID = `ID_LBU;
            endcase
        end

        `OPCODE_I_STORE: begin
            {ID_rs1_vld, ID_rs2_vld, ID_rd_vld} = 3'b110;
            ID_imm = { {20{inst[31]}}, inst[31:25], inst[11:7] };
            case (inst[14:12])
                `FUNCT3_SW: ID_instID = `ID_SW;
                `FUNCT3_SB: ID_instID = `ID_SB;
                `FUNCT3_SH: ID_instID = `ID_SH;
            endcase
        end

    endcase
end

endmodule