// 2**12 = 'd4096 = 'h1000
`define InstCatchDepth 12

// 因为riscv-isa设定数据在ram中的起始地址为0x1000, 所以到时候地址只取[11:0]
`define DataCatchDepth 12

`define InstIDDepth 8

// I-TYPE of Computational Instructions
`define OPCODE_I_COMPU 7'b0010011

`define FUNCT3_ADDI 3'b000
`define ID_ADDI 8'd2

`define FUNCT3_ANDI 3'b111
`define ID_ANDI 8'd3

// I-TYPE of Load Instructions
`define OPCODE_I_LOAD 7'b0000011

`define FUNCT3_LW 3'b010
`define ID_LW 8'd28

`define FUNCT3_LH 3'b001
`define ID_LH 8'd26

// I-TYPE of Store Instructions
`define OPCODE_I_STORE 7'b0100011

`define FUNCT3_SW 3'b010
`define ID_SW 8'd31

// R-TYPE
`define OPCODE_R 7'b0110011
`define FUNCT3_ADD 3'b000
`define ID_ADD 8'd11

`define FUNCT3_AND 3'b111
`define ID_AND 8'd13

// FUNCT3_SUB = FUNCT3_ADD = 3'b000
`define ID_SUB 8'd12

// U-TYPE
`define OPCODE_U_LUI 7'b0110111
`define ID_LUI 8'd21

`define OPCODE_U_AUIPC 7'b0010111
`define ID_AUIPC 8'd23

// B-TYPE
`define OPCODE_B 7'b1100011

`define FUNCT3_BNE 3'b001
`define ID_BNE 8'd33

`define FUNCT3_BEQ 3'b000
`define ID_BEQ 8'd32

`define FUNCT3_BGE 3'b101
`define ID_BGE 8'd34

`define FUNCT3_BGEU 3'b111
`define ID_BGEU 8'd35

`define FUNCT3_BLT 3'b100
`define ID_BLT 8'd36

`define FUNCT3_BLTU 3'b110
`define ID_BLTU 8'd37

// J-TYPE
`define OPCODE_J_JAL 7'b1101111
`define ID_JAL 8'd38

`define OPCODE_J_JALR 7'b1100111
`define ID_JALR 8'd39
