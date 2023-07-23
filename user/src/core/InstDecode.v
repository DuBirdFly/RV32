`include "defines.v"

module InstructionDecode(
    input                           clk,
    input                           hold,
    
    input       [31:0]              inst,       // from InstructionFetch

    output reg  [4:0]               rs1, rs2,   // 读取x32寄存器堆, to RegisterFile
    output reg  [4:0]               rd,         // 写入x32寄存器堆的目标地址, 打2拍后 to WriteBack
    output reg  [31:0]              imm,        // 生成32位的立即数 (大概率要符号拓展)
    output reg  [`InstIDDepth-1:0]  instID,     // 生成instID, 如: ID_ADDI=8'd2; ID_BNE=8'd33

    output reg                      error
);

always @(posedge clk) begin
    
    case (inst[6:0])
        `OPCODE_I_COMPU:
            case (inst[14:12])
                `FUNCT3_ADDI: begin
                    imm <= { {20{inst[31]}}, inst[31:20] };     // 符号扩展
                    rs1 <= inst[19:15];
                    rd <= inst[11:7];
                    instID <= `ID_ADDI;
                end
                default: error <= 1'd1;
            endcase

        `OPCODE_R:
            case (inst[14:12])
                `FUNCT3_ADD: begin
                    rs1 <= inst[19:15];
                    rs2 <= inst[24:20];
                    rd <= inst[11:7];
                    instID <= `ID_ADD;
                end
                default: error <= 1'd1;
            endcase
        
        `OPCODE_U_LUI: begin
            imm <= {  inst[31:12] , 12'd0 }; 
            rd <= inst[11:7];
            instID <= `ID_LUI;
        end

        `OPCODE_B:
            case (inst[14:12])
                `FUNCT3_BNE: begin
                    imm <= { {19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0 };
                    rs1 <= inst[19:15];
                    rs2 <= inst[24:20];
                    instID <= `ID_BNE;
                end
                default: error <= 1'd1;
            endcase

        `OPCODE_J_JAL: begin
            imm <= { {12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0 };
            rd <= inst[11:7];
            instID <= `ID_JAL;
        end

        `OPCODE_I_LW:
            case (inst[14:12])
                `FUNCT3_LW: begin
                    imm <= { {20{inst[31]}}, inst[31:20] };
                    rs1 <= inst[19:15];
                    rd <= inst[11:7];
                    instID <= `ID_LW;
                end
                default: error <= 1'd1;
            endcase

        `OPCODE_I_SW:
            case (inst[14:12])
                `FUNCT3_SW: begin
                    imm <= { {20{inst[31]}}, inst[31:25], inst[11:7] };
                    rs1 <= inst[19:15];
                    rs2 <= inst[24:20];
                    instID <= `ID_SW;
                end
                default: error <= 1'd1;
            endcase

        default: error <= 1'd1;
    endcase
    
end

endmodule