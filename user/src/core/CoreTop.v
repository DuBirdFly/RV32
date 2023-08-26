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
wire [6:0]                  ID_opcode;
wire [4:0]                  ID_rs1, ID_rs2, ID_rd;
wire                        ID_rs1_vld, ID_rs2_vld, ID_rd_vld;
wire [31:0]                 ID_imm;
wire [`InstIDDepth-1:0]     ID_instID;
wire                        ID_jmp_vld;

InstDecode u_InstDecode(
    .inst           ( IF_inst     ),
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
wire                        ID_REG_rs1_vld;
wire                        ID_REG_rs2_vld;
wire                        ID_REG_rd_vld;
wire [31:0]                 ID_REG_imm;
wire [`InstIDDepth-1:0]     ID_REG_instID;
wire                        ID_REG_jmp_vld;

InstDecodeReg u_InstDecodeReg(
    .clk                ( clk             ),
    // from InstFetch, to Execute
    .pc                 ( IF_pc           ),
    .ID_REG_pc          ( ID_REG_pc       ),
    // from InstDecode
    .opcode             ( ID_opcode       ),
    .rs1                ( ID_rs1          ),
    .rs2                ( ID_rs2          ),
    .rd                 ( ID_rd           ),
    .rs1_vld            ( ID_rs1_vld      ),
    .rs2_vld            ( ID_rs2_vld      ),
    .rd_vld             ( ID_rd_vld       ),
    .imm                ( ID_imm          ),
    .instID             ( ID_instID       ),
    // to Execute
    .ID_REG_opcode      ( ID_REG_opcode   ),
    .ID_REG_rs1         ( ID_REG_rs1      ),
    .ID_REG_rs2         ( ID_REG_rs2      ),
    .ID_REG_rd          ( ID_REG_rd       ),
    .ID_REG_rs1_vld     ( ID_REG_rs1_vld  ),
    .ID_REG_rs2_vld     ( ID_REG_rs2_vld  ),
    .ID_REG_rd_vld      ( ID_REG_rd_vld   ),
    .ID_REG_imm         ( ID_REG_imm      ),
    .ID_REG_instID      ( ID_REG_instID   )
);

// Register File -----------------------------------------
wire [4:0]                  REGS_rdaddr1, REGS_rdaddr2;
wire                        REGS_wen;
wire [4:0]                  REGS_wraddr;
wire [31:0]                 REGS_wrdata;

wire [31:0]                 REGS_rddata1;// o
wire [31:0]                 REGS_rddata2;// o

assign REGS_rdaddr1 = ID_REG_rs1;
assign REGS_rdaddr2 = ID_REG_rs2;

Registers u_Registers(
    .clk              ( clk           ),
    .REGS_rdaddr1     ( REGS_rdaddr1  ),
    .REGS_rddata1     ( REGS_rddata1  ),// o
    .REGS_rdaddr2     ( REGS_rdaddr2  ),
    .REGS_rddata2     ( REGS_rddata2  ),// o
    .REGS_wen         ( REGS_wen      ),
    .REGS_wraddr      ( REGS_wraddr   ),
    .REGS_wrdata      ( REGS_wrdata   )
);

// Execute -----------------------------------------------
wire                        inst_vld_EX;

wire [31:0]                 OF_x_rs1, OF_x_rs2;

wire                        EX_jmp_vld;
wire [31:0]                 EX_jmp_addr;
wire [4:0]                  EX_rd;
wire [31:0]                 EX_x_rd;
wire                        EX_x_rd_vld;
wire [31:0]                 EX_MEMaddr;
wire [3:0]                  EX_MEMrden, EX_MEMwren;
wire                        EX_MEMrden_SEXT;
wire [31:0]                 EX_MEMwrdata;

Execute u_Execute(
    .clk              ( clk           ),
    .inst_vld         ( inst_vld_EX   ),

    .instID           ( ID_REG_instID ),
    .rd               ( ID_REG_rd     ),
    .x_rs1            ( OF_x_rs1      ),
    .x_rs2            ( OF_x_rs2      ),
    .imm              ( ID_REG_imm    ),
    .pc               ( ID_REG_pc     ),
    .x_rd_vld         ( ID_REG_rd_vld ),

    .EX_jmp_vld       ( EX_jmp_vld    ),
    .EX_jmp_addr      ( EX_jmp_addr   ),

    .EX_rd            ( EX_rd         ),
    .EX_x_rd          ( EX_x_rd       ),
    .EX_x_rd_vld      ( EX_x_rd_vld   ),

    .EX_MEMaddr       ( EX_MEMaddr    ),
    .EX_MEMrden       ( EX_MEMrden    ),
    .EX_MEMrden_SEXT  ( EX_MEMrden_SEXT ),
    .EX_MEMwren       ( EX_MEMwren    ),
    .EX_MEMwrdata     ( EX_MEMwrdata  )
);

// Memory Access ------------------------------------------
wire                        MEM_x_rd_vld;
wire [31:0]                 MEM_x_rd;
wire [4:0]                  MEM_rd;

MemAccess u_MemAccess(
    .clk              ( clk           ),
    .rd               ( EX_rd         ),
    .x_rd             ( EX_x_rd       ),
    .x_rd_vld         ( EX_x_rd_vld   ),
    .addr             ( EX_MEMaddr    ),
    .rden_SEXT        ( EX_MEMrden_SEXT ),
    .rden             ( EX_MEMrden    ),
    .wren             ( EX_MEMwren    ),
    .wrdata           ( EX_MEMwrdata  ),
    .MEM_rd           ( MEM_rd        ),
    .MEM_x_rd         ( MEM_x_rd      ),
    .MEM_x_rd_vld     ( MEM_x_rd_vld  )
);

// Write Back ---------------------------------------------
assign REGS_wen = MEM_x_rd_vld;
assign REGS_wraddr = MEM_rd;
assign REGS_wrdata = MEM_x_rd;

// Operand Forwarding -------------------------------------
OpdForward u_OpdForward(
    .EX_rd            ( EX_rd         ),
    .EX_x_rd          ( EX_x_rd       ),
    .EX_x_rd_vld      ( EX_x_rd_vld   ),
    .REGS_rdaddr1     ( REGS_rdaddr1  ),
    .REGS_rdaddr2     ( REGS_rdaddr2  ),
    .REGS_rddata1     ( REGS_rddata1  ),
    .REGS_rddata2     ( REGS_rddata2  ),
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
    .ID_pc            ( IF_pc         ),
    .EX_jmp_vld       ( EX_jmp_vld    ),
    .EX_jmp_addr      ( EX_jmp_addr   ),
    // output
    .jmp_vld_IF       ( jmp_vld_IF    ),
    .jmp_addr_IF      ( jmp_addr_IF   ),
    .inst_vld_EX      ( inst_vld_EX   )
);


endmodule