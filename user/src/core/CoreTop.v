`include "../inc/defines.v"
// `include "defines.v"

module CoreTop(
    input  clk,
    input  rst
);

// Instruction Fetch -------------------------------------
wire                        hold_IF;
wire                        jmp_vld_IF;
wire [31:0]                 jmp_addr_IF;

wire [31:0]                 IF_pc;
wire [31:0]                 IF_inst;

InstFetch u_InstFetch(
    .clk         ( clk          ),
    .rst         ( rst          ),
    .hold        ( hold_IF      ),
    .jmp_vld     ( jmp_vld_IF   ),
    .jmp_addr    ( jmp_addr_IF  ),
    .IF_pc       ( IF_pc        ),
    .IF_inst     ( IF_inst      )
);

// Instruction Decode ------------------------------------
wire [31:0]                 ID_pc;
wire [6:0]                  ID_opcode;
wire [4:0]                  ID_rs1, ID_rs2, ID_rd;
wire                        ID_rs1_vld, ID_rs2_vld, ID_rd_vld;
wire [31:0]                 ID_imm;
wire [`InstIDDepth-1:0]     ID_instID;
wire                        ID_jmp_vld;

InstDecode u_InstDecode(
    .inst           ( IF_inst     ),
    .pc             ( IF_pc       ),
    .ID_pc          ( ID_pc       ),
    // decode
    .ID_opcode      ( ID_opcode   ),
    .ID_rs1         ( ID_rs1      ),
    .ID_rs2         ( ID_rs2      ),
    .ID_rd          ( ID_rd       ),
    .ID_rs1_vld     ( ID_rs1_vld  ),
    .ID_rs2_vld     ( ID_rs2_vld  ),
    .ID_rd_vld      ( ID_rd_vld   ),
    .ID_imm         ( ID_imm      ),
    // instID
    .ID_instID      ( ID_instID   ),
    // jump for unconditonal jump
    .ID_jmp_vld     ( ID_jmp_vld  )
);

// Instruction Decode Reg delay --------------------------
wire [31:0]                 ID_REG_pc;
wire [6:0]                  ID_REG_opcode;
wire [4:0]                  ID_REG_rs1;
wire [4:0]                  ID_REG_rs2;
wire [4:0]                  ID_REG_rd;
wire                        ID_REG_rd_vld;
wire [31:0]                 ID_REG_imm;
wire [`InstIDDepth-1:0]     ID_REG_instID;
wire                        ID_REG_jmp_vld;

InstDecodeReg u_InstDecodeReg(
    .clk                ( clk             ),
    // from InstFetch, to Execute
    .pc                 ( ID_pc           ),
    .ID_REG_pc          ( ID_REG_pc       ),
    // from InstDecode
    .opcode             ( ID_opcode       ),
    .rs1                ( ID_rs1          ),
    .rs2                ( ID_rs2          ),
    .rd                 ( ID_rd           ),
    .rd_vld             ( ID_rd_vld       ),
    .imm                ( ID_imm          ),
    .instID             ( ID_instID       ),
    // to Execute
    .ID_REG_opcode      ( ID_REG_opcode   ),
    .ID_REG_rs1         ( ID_REG_rs1      ),
    .ID_REG_rs2         ( ID_REG_rs2      ),
    .ID_REG_rd          ( ID_REG_rd       ),
    .ID_REG_rd_vld      ( ID_REG_rd_vld   ),
    .ID_REG_imm         ( ID_REG_imm      ),
    .ID_REG_instID      ( ID_REG_instID   )
);

// Execute -----------------------------------------------
wire                        inst_vld_EX;

wire [31:0]                 OF_x_rs1, OF_x_rs2;

wire                        EX_jmp_vld;
wire [31:0]                 EX_jmp_addr;
wire [4:0]                  EX_rd;
wire [31:0]                 EX_x_rd;
wire                        EX_rd_vld;
wire [31:0]                 EX_MEM_addr;
wire [3:0]                  EX_MEM_rden;
wire                        EX_MEM_rden_SEXT;
wire [3:0]                  EX_MEM_wren;
wire [31:0]                 EX_MEM_wrdata;

Execute u_Execute(
    .clk              ( clk           ),
    .inst_vld         ( inst_vld_EX   ),

    .instID           ( ID_REG_instID ),
    .rd               ( ID_REG_rd     ),
    .x_rs1            ( OF_x_rs1      ),
    .x_rs2            ( OF_x_rs2      ),
    .imm              ( ID_REG_imm    ),
    .pc               ( ID_REG_pc     ),
    .rd_vld           ( ID_REG_rd_vld ),

    .EX_jmp_vld       ( EX_jmp_vld    ),
    .EX_jmp_addr      ( EX_jmp_addr   ),

    .EX_rd            ( EX_rd         ),
    .EX_rd_vld        ( EX_rd_vld     ),
    .EX_x_rd          ( EX_x_rd       ),

    .EX_MEM_addr      ( EX_MEM_addr   ),
    .EX_MEM_rden      ( EX_MEM_rden   ),
    .EX_MEM_rden_SEXT ( EX_MEM_rden_SEXT ),
    .EX_MEM_wren      ( EX_MEM_wren   ),
    .EX_MEM_wrdata    ( EX_MEM_wrdata )
);

// Memory Access ------------------------------------------
wire                        MEM_rd_vld;
wire [31:0]                 MEM_x_rd;
wire [4:0]                  MEM_rd;

MemAccess u_MemAccess(
    .clk              ( clk           ),
    .rd               ( EX_rd         ),
    .rd_vld           ( EX_rd_vld     ),
    .x_rd             ( EX_x_rd       ),
    .addr             ( EX_MEM_addr   ),
    .rden_SEXT        ( EX_MEM_rden_SEXT ),
    .rden             ( EX_MEM_rden   ),
    .wren             ( EX_MEM_wren   ),
    .wrdata           ( EX_MEM_wrdata ),
    .MEM_rd           ( MEM_rd        ),
    .MEM_x_rd         ( MEM_x_rd      ),
    .MEM_rd_vld       ( MEM_rd_vld    )
);

// Register File -----------------------------------------
wire [31:0]                 REGS_rddata1;// o
wire [31:0]                 REGS_rddata2;// o

Registers u_Registers(
    .clk              ( clk           ),
    .rdaddr1          ( ID_rs1        ),
    .REGS_rddata1     ( REGS_rddata1  ),// o
    .rdaddr2          ( ID_rs2        ),
    .REGS_rddata2     ( REGS_rddata2  ),// o
    .wen              ( MEM_rd_vld    ),
    .wraddr           ( MEM_rd        ),
    .wrdata           ( MEM_x_rd      )
);

// Operand Forwarding -------------------------------------
OpdForward u_OpdForward(
    // from EX
    .EX_rd            ( EX_rd         ),
    .EX_x_rd          ( EX_x_rd       ),
    .EX_rd_vld        ( EX_rd_vld     ),
    // from MEM
    .MEM_rd           ( MEM_rd        ),
    .MEM_x_rd         ( MEM_x_rd      ),
    .MEM_rd_vld       ( MEM_rd_vld    ),
    // from ID_REG
    .ID_REG_rs1       ( ID_REG_rs1    ),
    .ID_REG_rs2       ( ID_REG_rs2    ),
    // from REGS
    .REGS_rddata1     ( REGS_rddata1  ),
    .REGS_rddata2     ( REGS_rddata2  ),
    // output
    .OF_x_rs1         ( OF_x_rs1      ),
    .OF_x_rs2         ( OF_x_rs2      )
);

// Control -----------------------------------------------
Control u_Control(
    .clk              ( clk           ),
    // input
    .ID_rs1           ( ID_rs1        ),
    .ID_rs2           ( ID_rs2        ),
    .ID_rs1_vld       ( ID_rs1_vld    ),
    .ID_rs2_vld       ( ID_rs2_vld    ),
    .ID_REG_rd        ( ID_REG_rd     ),
    .ID_REG_opcode    ( ID_REG_opcode ),
    // output
    .hold_IF          ( hold_IF       ),
    // input
    .ID_jmp_vld       ( ID_jmp_vld    ),
    .ID_imm           ( ID_imm        ),
    .ID_pc            ( ID_pc         ),
    .EX_jmp_vld       ( EX_jmp_vld    ),
    .EX_jmp_addr      ( EX_jmp_addr   ),
    // output
    .jmp_vld_IF       ( jmp_vld_IF    ),
    .jmp_addr_IF      ( jmp_addr_IF   ),
    .inst_vld_EX      ( inst_vld_EX   )
);


endmodule