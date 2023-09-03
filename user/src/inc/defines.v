/*
老的测试集中:
  1. 地址的粒度
    RV32I的指令地址的粒度是4Byte, 也就是说, 指令地址的最低两位是0
    RV32I的数据地址的粒度是1Byte, 希望每一个数据地址都可以读写 8bit 的数据
  2. 指令
    2.1 指令地址
      因为 jump 和 branch 指令返回的地址是32位的, 所以定义 PC 寄存器的宽度为 32
      但实际上, 有效的指令地址的范围为: 0x00000000 ~ 0x00000FFC (必须是4的倍数)
      [注: 2**12 = 'd4096 = 'h1000]
      [注: 8bit * 0x1000 = 0x1000 * 1Byte = 4KB]
    2.2 BRAM of ICatch
      由于我想设置BRAM的宽度为32位, 所以定义BRAM的地址宽度是 [11:2] --> [9:0] (10位)
      [注: 32bit * 2**10 = 4Byte * 1024 = 4KB]
  3. 数据
    3.1 数据地址
      数据地址的范围为: 0x00001000 ~ 0x00001FFF (每一个地址都可以读写 8bit 的数据)
      [注: 2**12 = 'd4096 = 'h1000]
      [注: 8bit * 0x1000 = 0x1000 * 1Byte = 4KB]
    3.2 BRAM of DCatch
      使用 4 个 8bit 宽度的 BRAM, 每一个 BRAM 的地址宽度是 [11:2] --> [9:0] (10位)
      [注: 8bit * 2**10 = 1Byte * 1024 = 1KB]
      [注: 4 * 1KB = 4KB]

ICatch地址范围 = 0x0 ~ 0xffc
DCatch地址范围 = 2**ICatchDepth ~ 2**ICatchDepth + 2**DCatchDepth - 1
              = 0x1000 ~ 0x1fff

综上, 定义的宏如下:
`define ICatchDepth 12
`define DCatchDepth 12
*/

`define ICatchDepth 12      // 此时 ICatch 的addr深度为 2 ** 10 = 1024
`define DCatchDepth 13

`define DCatchStartAddr (2**`ICatchDepth)       // 此时 DCatch 的addr深度为 2 ** 12 = 0x1000

`define InstIDDepth 8

// R-TYPE of Computational Instructions
`define OPCODE_R 7'b0110011

`define FUNCT3_ADD 3'b000   // FUNCT3_SUB = FUNCT3_ADD = 3'b000
`define ID_ADD 8'd1
`define ID_SUB 8'd2        

`define FUNCT3_SLL 3'b001
`define ID_SLL 8'd3         // Shift Left Logical

`define FUNCT3_SLT 3'b010
`define ID_SLT 8'd4         // Set if Less Than

`define FUNCT3_SLTU 3'b011
`define ID_SLTU 8'd5        // Set if Less Than, Unsigned

`define FUNCT3_XOR 3'b100
`define ID_XOR 8'd6

`define FUNCT3_SRL 3'b101   // FUNCT3_SRA = FUNCT3_SRL = 3'b101
`define ID_SRL 8'd7         // Shift Right Logical (unsigned)
`define ID_SRA 8'd8         // Shift Right Arithmetic (signed)

`define FUNCT3_OR 3'b110
`define ID_OR 8'd9

`define FUNCT3_AND 3'b111
`define ID_AND 8'd10

// I-TYPE of Computational Instructions
`define OPCODE_I_COMPU 7'b0010011

`define FUNCT3_ADDI 3'b000
`define ID_ADDI 8'd11

`define FUNCT3_SLLI 3'b001
`define ID_SLLI 8'd12       // Shift Left Logical Immediate

`define FUNCT3_SLTI 3'b010
`define ID_SLTI 8'd13       // Set if Less Than, Immediate

`define FUNCT3_SLTIU 3'b011
`define ID_SLTIU 8'd14      // Set if Less Than, Immediate, Unsigned

`define FUNCT3_XORI 3'b100
`define ID_XORI 8'd15

`define FUNCT3_SRLI 3'b101  // FUNCT3_SRAI = FUNCT3_SRLI = 3'b101
`define ID_SRLI 8'd16       // Shift Right Logical Immediate (unsigned)
`define ID_SRAI 8'd17       // Shift Right Arithmetic Immediate (signed)

`define FUNCT3_ORI 3'b110
`define ID_ORI 8'd18

`define FUNCT3_ANDI 3'b111
`define ID_ANDI 8'd19

// I-TYPE of Jump Instructions
`define OPCODE_J_JALR 7'b1100111
`define ID_JALR 8'd20

// I-TYPE of Load Instructions
`define OPCODE_I_LOAD 7'b0000011

`define FUNCT3_LB 3'b000
`define ID_LB 8'd21         // Load Byte

`define FUNCT3_LH 3'b001
`define ID_LH 8'd22         // Load Halfword

`define FUNCT3_LW 3'b010
`define ID_LW 8'd23         // Load Word

`define FUNCT3_LBU 3'b100
`define ID_LBU 8'd24        // Load Byte, Unsigned

`define FUNCT3_LHU 3'b101
`define ID_LHU 8'd25        // Load Halfword, Unsigned

// S-TYPE of Store Instructions
`define OPCODE_I_STORE 7'b0100011

`define FUNCT3_SB 3'b000
`define ID_SB 8'd26         // Store Byte

`define FUNCT3_SH 3'b001
`define ID_SH 8'd37         // Store Halfword

`define FUNCT3_SW 3'b010
`define ID_SW 8'd28         // Store Word

// B-TYPE of Branch Instructions
`define OPCODE_B 7'b1100011

`define FUNCT3_BEQ 3'b000
`define ID_BEQ 8'd29        // Branch if Equal

`define FUNCT3_BNE 3'b001
`define ID_BNE 8'd30        // Branch if Not Equal

`define FUNCT3_BLT 3'b100
`define ID_BLT 8'd31        // Branch if Less Than

`define FUNCT3_BGE 3'b101
`define ID_BGE 8'd32        // Branch if Greater or Equal

`define FUNCT3_BLTU 3'b110
`define ID_BLTU 8'd33       // Branch if Less Than, Unsigned

`define FUNCT3_BGEU 3'b111
`define ID_BGEU 8'd34       // Branch if Greater or Equal, Unsigned

// U-TYPE of Upper Immediate Instructions
`define OPCODE_U_LUI 7'b0110111
`define ID_LUI 8'd35

`define OPCODE_U_AUIPC 7'b0010111
`define ID_AUIPC 8'd36

// J-TYPE of Jump Instructions
`define OPCODE_J_JAL 7'b1101111
`define ID_JAL 8'd37

// I-TYPE of CSR and System Instructions
`define OPCODE_I_SYS 7'b1110011

`define FUNCT3_CSRRW 3'b001
`define ID_CSRRW 8'd38      // CSR Read/Write

`define FUNCT3_CSRRS 3'b010
`define ID_CSRRS 8'd39      // CSR Read/Set

`define FUNCT3_CSRRC 3'b011
`define ID_CSRRC 8'd40      // CSR Read/Clear

`define FUNCT3_CSRRWI 3'b101
`define ID_CSRRWI 8'd41     // CSR Read/Write Immediate

`define FUNCT3_CSRRSI 3'b110
`define ID_CSRRSI 8'd42     // CSR Read/Set Immediate

`define FUNCT3_CSRRCI 3'b111
`define ID_CSRRCI 8'd43     // CSR Read/Clear Immediate

`define CSRs_ADDR_MTVEC 12'h305
`define CSRs_ADDR_MEPC 12'h341
`define CSRs_ADDR_MCAUSE 12'h342
`define CSRs_ADDR_MIE 12'h304
`define CSRs_ADDR_MIP 12'h344
`define CSRs_ADDR_MTVAL 12'h343
`define CSRs_ADDR_MSTATUS 12'h300
`define CSRs_ADDR_MSCRATCH 12'h340
`define CSRs_ADDR_CYCLE_LOW 12'hC00
`define CSRs_ADDR_CYCLE_HIGH 12'hC80

`define FUNCT3_ECALL 3'b000 // FUNCT3_EBREAK = FUNCT3_ECALL = FUNCT3_MRET = 3'b000

`define IMM12_ECALL 12'b000000000000
`define ID_ECALL 8'd44      // Environment Call

`define IMM12_EBREAK 12'b000000000001
`define ID_EBREAK 8'd45     // Environment Break

`define IMM12_MRET 12'b001100000010
`define ID_MRET 8'd46       // Machine Return

// R-TYPE of RV32M (Integer Multiply and Divide Instructions)
`define OPCODE_RV32M 7'b0111011

`define FUNCT3_MUL 3'b000
`define ID_MUL 8'd47        // Multiply

`define FUNCT3_MULH 3'b001
`define ID_MULH 8'd48       // Multiply High Signed

`define FUNCT3_MULHSU 3'b010
`define ID_MULHSU 8'd49     // Multiply High Signed and Unsigned

`define FUNCT3_MULHU 3'b011
`define ID_MULHU 8'd50      // Multiply High Unsigned

`define FUNCT3_DIV 3'b100
`define ID_DIV 8'd51        // Divide Signed

`define FUNCT3_DIVU 3'b101
`define ID_DIVU 8'd52       // Divide Unsigned

`define FUNCT3_REM 3'b110
`define ID_REM 8'd53        // Remainder Signed

`define FUNCT3_REMU 3'b111
`define ID_REMU 8'd54       // Remainder Unsigned
