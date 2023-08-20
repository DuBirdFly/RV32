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

`define FUNCT3_ORI 3'b110
`define ID_ORI 8'd4

`define FUNCT3_XORI 3'b100
`define ID_XORI 8'd5

`define FUNCT3_SLTI 3'b010
`define ID_SLTI 8'd6

`define FUNCT3_SLTIU 3'b011
`define ID_SLTIU 8'd7

`define FUNCT3_SLLI 3'b001
`define ID_SLLI 8'd8

`define FUNCT3_SRLI 3'b101
`define ID_SRLI 8'd9
`define ID_SRAI 8'd10

// I-TYPE of Load Instructions
`define OPCODE_I_LOAD 7'b0000011

`define FUNCT3_LW 3'b010
`define ID_LW 8'd28

`define FUNCT3_LH 3'b001
`define ID_LH 8'd26

`define FUNCT3_LB 3'b000
`define ID_LB 8'd24

`define FUNCT3_LHU 3'b101
`define ID_LHU 8'd27

`define FUNCT3_LBU 3'b100
`define ID_LBU 8'd25

// I-TYPE of Store Instructions
`define OPCODE_I_STORE 7'b0100011

`define FUNCT3_SW 3'b010
`define ID_SW 8'd31

`define FUNCT3_SB 3'b000
`define ID_SB 8'd29

`define FUNCT3_SH 3'b001
`define ID_SH 8'd30

// R-TYPE
`define OPCODE_R 7'b0110011
`define FUNCT3_ADD 3'b000
`define ID_ADD 8'd11

`define FUNCT3_AND 3'b111
`define ID_AND 8'd13

`define FUNCT3_OR 3'b110
`define ID_OR 8'd14

`define FUNCT3_XOR 3'b100
`define ID_XOR 8'd15

`define FUNCT3_SLL 3'b001
`define ID_SLL 8'd16

`define FUNCT3_SRL 3'b101
`define ID_SRL 8'd17
`define ID_SRA 8'd18

`define FUNCT3_SLT 3'b010
`define ID_SLT 8'd19

`define FUNCT3_SLTU 3'b011
`define ID_SLTU 8'd20

// FUNCT3_SUB = FUNCT3_ADD = 3'b000
`define ID_SUB 8'd12

// U-TYPE
`define OPCODE_U_LUI 7'b0110111
`define ID_LUI 8'd21

`define OPCODE_U_AUIPC 7'b0010111
`define ID_AUIPC 8'd22

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
