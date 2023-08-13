// 2**12 = 'd4096 = 'h1000
`define InstCatchDepth 12

// 因为riscv-isa设定数据在ram中的起始地址为0x1000, 所以到时候地址只取[11:0]
`define DataCatchDepth 12

`define InstIDDepth 8

// I-TYPE of Computational Instructions
`define OPCODE_I_COMPU 7'b0010011
`define FUNCT3_ADDI 3'b000
`define ID_ADDI 8'd2

// I-TYPE of Load Instructions
`define OPCODE_I_LW 7'b0000011
`define FUNCT3_LW 3'b010
`define ID_LW 8'd28

`define OPCODE_I_SW 7'b0100011
`define FUNCT3_SW 3'b010
`define ID_SW 8'd31

// R-TYPE
`define OPCODE_R 7'b0110011
`define FUNCT3_ADD 3'b000
`define ID_ADD 8'd11

// U-TYPE
`define OPCODE_U_LUI 7'b0110111
`define ID_LUI 8'd21

// B-TYPE
`define OPCODE_B 7'b1100011
`define FUNCT3_BNE 3'b001
`define ID_BNE 8'd33

// J-TYPE
`define OPCODE_J_JAL 7'b1101111
`define ID_JAL 8'd38

