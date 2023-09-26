`include "../inc/defines.v"

module InstDecode(
    // from IF
    input       [31:0]             inst,                   
    input       [31:0]             pc,
    // instID
    output      [31:0]             ID_pc,
    output reg  [`InstIDDepth-1:0] ID_instID,              // define的instID, 如: ID_ADDI=8'd2; ID_BNE=8'd33
    // 译码输出1
    output wire [6:0]              ID_opcode,
    output wire [4:0]              ID_rs1, ID_rs2, ID_rd,  // 读32位寄存器地址1, 2; 写32位寄存器地址
    output reg                     ID_rs1_vld, ID_rs2_vld, ID_rd_vld,
    output reg  [31:0]             ID_imm,                 // 32位的立即数 (大概率要符号拓展)
    // 译码输出2
    output reg  [11:0]             ID_csr,          // 读/写 CSR的地址 (CSRR 系列指令都是对同一个地址进行读写操作的)
    // 控制冒险: 无条件跳转 (只有 OPCODE_J_JAL 才会触发， 立即反馈到 IF， 此时的jmp_addr = imm)
    output wire                    ID_jmp_vld              // 生成跳转信号, to IF
);

// ID的pc = IF的pc
assign ID_pc = pc;

// opcode, rs1, rs2, rd 都是固定位置的
assign ID_opcode = inst[6:0];
assign ID_rs2 = inst[24:20];
assign ID_rs1 = inst[19:15];
assign ID_rd = inst[11:7];

// ID_imm 只有 4 种排列情况
wire [31:0] imm_i_tpye, imm_s_tpye, imm_b_type, imm_u_tpye, imm_j_type, imm_z_type;

assign imm_i_tpye = { {20{inst[31]}}, inst[31:20] };
assign imm_s_tpye = { {20{inst[31]}}, inst[31:25], inst[11:7] };
assign imm_b_type = { {19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0 };
assign imm_u_tpye = { inst[31:12] , 12'd0 };
assign imm_j_type = { {11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0 };

// 处理无条件跳转型数据冒险: 立即反馈到 IF， 执行跳转
assign ID_jmp_vld = (ID_opcode == `OPCODE_J_JAL);

// 转为组合逻辑
always @(*) begin
    ID_imm = imm_i_tpye;
    ID_instID = 'd0;
    {ID_rs1_vld, ID_rs2_vld, ID_rd_vld} = 3'b000;

    case (ID_opcode)
        `OPCODE_I_COMPU:begin
            {ID_rs1_vld, ID_rs2_vld, ID_rd_vld} = 3'b101;
            ID_imm = imm_i_tpye;
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
            ID_imm = imm_u_tpye; 
            ID_instID = `ID_LUI;
        end

        `OPCODE_U_AUIPC: begin
            {ID_rs1_vld, ID_rs2_vld, ID_rd_vld} = 3'b001;
            ID_imm = imm_u_tpye; 
            ID_instID = `ID_AUIPC;
        end

        `OPCODE_B: begin
            {ID_rs1_vld, ID_rs2_vld, ID_rd_vld} = 3'b110;
            ID_imm = imm_b_type;
            case (inst[14:12])
                `FUNCT3_BNE:  ID_instID = `ID_BNE;
                `FUNCT3_BEQ:  ID_instID = `ID_BEQ;
                `FUNCT3_BGE:  ID_instID = `ID_BGE;
                `FUNCT3_BGEU: ID_instID = `ID_BGEU;
                `FUNCT3_BLT:  ID_instID = `ID_BLT;
                `FUNCT3_BLTU: ID_instID = `ID_BLTU;
                default: ID_instID = 'd0;
            endcase
        end

        `OPCODE_J_JAL: begin
            {ID_rs1_vld, ID_rs2_vld, ID_rd_vld} = 3'b001;
            ID_imm = imm_j_type;
            ID_instID = `ID_JAL;
        end

        `OPCODE_J_JALR: begin
            {ID_rs1_vld, ID_rs2_vld, ID_rd_vld} = 3'b101;
            ID_imm = imm_i_tpye;
            ID_instID = `ID_JALR;
        end

        `OPCODE_I_LOAD: begin
            {ID_rs1_vld, ID_rs2_vld, ID_rd_vld} = 3'b101;
            ID_imm = imm_i_tpye;
            case (inst[14:12])
                `FUNCT3_LW: ID_instID = `ID_LW;
                `FUNCT3_LH: ID_instID = `ID_LH;
                `FUNCT3_LB: ID_instID = `ID_LB;
                `FUNCT3_LHU: ID_instID = `ID_LHU;
                `FUNCT3_LBU: ID_instID = `ID_LBU;
                default: ID_instID = 'd0;
            endcase
        end

        `OPCODE_I_STORE: begin
            {ID_rs1_vld, ID_rs2_vld, ID_rd_vld} = 3'b110;
            ID_imm = imm_s_tpye;
            case (inst[14:12])
                `FUNCT3_SW: ID_instID = `ID_SW;
                `FUNCT3_SB: ID_instID = `ID_SB;
                `FUNCT3_SH: ID_instID = `ID_SH;
                default: ID_instID = 'd0;
            endcase
        end

        `OPCODE_I_SYS: begin
            if (inst[14:12] == `FUNCT3_ECALL) begin
                {ID_rs1_vld, ID_rs2_vld, ID_rd_vld} = 3'b000;
                case (inst[31:20])
                    `IMM12_ECALL: begin
                        ID_instID = `ID_ECALL;
                        ID_csr = `CSRs_ADDR_MTVEC;
                    end
                    `IMM12_MRET: begin
                        ID_instID = `ID_MRET;
                    end
                endcase
            end
            else begin
                {ID_rs1_vld, ID_rs2_vld, ID_rd_vld} = 3'b101;
                ID_csr = inst[31:20];
                case (inst[14:12])
                    `FUNCT3_CSRRW: ID_instID = `ID_CSRRW;
                    `FUNCT3_CSRRS: ID_instID = `ID_CSRRS;
                    `FUNCT3_CSRRC: ID_instID = `ID_CSRRC;
                    `FUNCT3_CSRRWI: ID_instID = `ID_CSRRWI;
                    `FUNCT3_CSRRSI: ID_instID = `ID_CSRRSI;
                    `FUNCT3_CSRRCI: ID_instID = `ID_CSRRCI;
                endcase
            end
        end
    endcase
end

endmodule