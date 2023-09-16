`include "../inc/defines.v"

module CoreTop(
    input  clk,
    input  rst
);

// Rstn Generator ----------------------------------------
// outports wire
wire                        srst_n;

RstnGen u_RstnGen(
    .clk         ( clk      ),
    .asrst_n     ( ~rst     ),
    .srst_n      ( srst_n   )
);

// Instruction Fetch -------------------------------------
wire                        hold_IF;
wire                        CTRL_IF_jmp_vld;
wire [31:0]                 CTRL_IF_jmp_addr;

wire [31:0]                 IF_pc;
wire [31:0]                 IF_inst;

InstFetch u_InstFetch(
    .clk         ( clk              ),
    .rst         ( ~srst_n          ),
    .hold        ( hold_IF          ),
    .jmp_vld     ( CTRL_IF_jmp_vld  ),
    .jmp_addr    ( CTRL_IF_jmp_addr ),
    .IF_pc       ( IF_pc            ),
    .IF_inst     ( IF_inst          )
);

// Instruction Decode ------------------------------------
wire [31:0]                 ID_pc;
wire [6:0]                  ID_opcode;
wire [4:0]                  ID_rs1, ID_rs2, ID_rd;
wire                        ID_rs1_vld, ID_rs2_vld, ID_rd_vld;
wire [31:0]                 ID_imm;
wire [`InstIDDepth-1:0]     ID_instID;
wire [11:0]                 ID_csr;
wire                        ID_jmp_vld;

InstDecode u_InstDecode(
    .inst           ( IF_inst     ),
    .pc             ( IF_pc       ),
    // instID
    .ID_pc          ( ID_pc       ),
    .ID_instID      ( ID_instID   ),
    // decode
    .ID_opcode      ( ID_opcode   ),
    .ID_rs1         ( ID_rs1      ),
    .ID_rs2         ( ID_rs2      ),
    .ID_rd          ( ID_rd       ),
    .ID_rs1_vld     ( ID_rs1_vld  ),
    .ID_rs2_vld     ( ID_rs2_vld  ),
    .ID_rd_vld      ( ID_rd_vld   ),
    .ID_imm         ( ID_imm      ),
    .ID_csr         ( ID_csr      ),
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
wire [11:0]                 ID_REG_csr;

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
    .csr                ( ID_csr          ),
    // to Execute / OpdForward
    .ID_REG_opcode      ( ID_REG_opcode   ),
    .ID_REG_rs1         ( ID_REG_rs1      ),
    .ID_REG_rs2         ( ID_REG_rs2      ),
    .ID_REG_rd          ( ID_REG_rd       ),
    .ID_REG_rd_vld      ( ID_REG_rd_vld   ),
    .ID_REG_imm         ( ID_REG_imm      ),
    .ID_REG_instID      ( ID_REG_instID   ),
    .ID_REG_csr         ( ID_REG_csr      )
);

// Execute -----------------------------------------------
wire                        CTRL_EX_en;

wire [31:0]                 OF_x_rs1, OF_x_rs2;
wire [31:0]                 OF_x_csr;

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
wire [11:0]                 EX_csr;
wire [31:0]                 EX_x_csr;
wire                        EX_csr_vld;

Execute u_Execute(
    .clk              ( clk           ),
    .en               ( CTRL_EX_en   ),

    .instID           ( ID_REG_instID ),
    .rs1              ( ID_REG_rs1    ),
    .rd               ( ID_REG_rd     ),
    .x_rs1            ( OF_x_rs1      ),
    .x_rs2            ( OF_x_rs2      ),
    .imm              ( ID_REG_imm    ),
    .pc               ( ID_REG_pc     ),
    .rd_vld           ( ID_REG_rd_vld ),

    .EX_jmp_vld       ( EX_jmp_vld    ),
    .EX_jmp_addr      ( EX_jmp_addr   ),

    .csr              ( ID_REG_csr    ),
    .x_csr            ( OF_x_csr      ),

    .EX_rd            ( EX_rd         ),
    .EX_rd_vld        ( EX_rd_vld     ),
    .EX_x_rd          ( EX_x_rd       ),

    .EX_MEM_addr      ( EX_MEM_addr   ),
    .EX_MEM_rden      ( EX_MEM_rden   ),
    .EX_MEM_rden_SEXT ( EX_MEM_rden_SEXT ),
    .EX_MEM_wren      ( EX_MEM_wren   ),
    .EX_MEM_wrdata    ( EX_MEM_wrdata ),

    .EX_csr           ( EX_csr        ),
    .EX_x_csr         ( EX_x_csr      ),
    .EX_csr_vld       ( EX_csr_vld    )
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
wire [31:0]                 REGs_rddata1;// o
wire [31:0]                 REGs_rddata2;// o

Registers u_REGs(
    .clk              ( clk           ),
    .rdaddr1          ( ID_rs1        ),
    .REGs_rddata1     ( REGs_rddata1  ),// o
    .rdaddr2          ( ID_rs2        ),
    .REGs_rddata2     ( REGs_rddata2  ),// o
    .wen              ( MEM_rd_vld    ),
    .wraddr           ( MEM_rd        ),
    .wrdata           ( MEM_x_rd      )
);

// CSRs --------------------------------------------------
wire [31:0]                 CSRs_rddata;

CSRs u_CSRs(
    .clk              ( clk         ),
    .rst              ( rst         ),
    .rdaddr           ( ID_csr      ),
    .CSRs_rddata      ( CSRs_rddata ),// o
    .wren             ( EX_csr_vld  ),
    .wraddr           ( EX_csr      ),
    .wrdata           ( EX_x_csr    ),
    .CSRs_glb_int_en  (             ) // o
);

// Operand Forwarding -------------------------------------
OpdForward u_OpdForward(
    // from EX
    .EX_rd            ( EX_rd         ),
    .EX_x_rd          ( EX_x_rd       ),
    .EX_rd_vld        ( EX_rd_vld     ),
    .EX_csr           ( EX_csr        ),
    .EX_x_csr         ( EX_x_csr      ),
    .EX_csr_vld       ( EX_csr_vld    ),
    // from MEM
    .MEM_rd           ( MEM_rd        ),
    .MEM_x_rd         ( MEM_x_rd      ),
    .MEM_rd_vld       ( MEM_rd_vld    ),
    // from ID_REG
    .ID_REG_rs1       ( ID_REG_rs1    ),
    .ID_REG_rs2       ( ID_REG_rs2    ),
    .ID_REG_csr       ( ID_REG_csr    ),
    // from REGS / CSRs
    .REGs_rddata1     ( REGs_rddata1  ),
    .REGs_rddata2     ( REGs_rddata2  ),
    .CSRs_rddata      ( CSRs_rddata   ),
    // output
    .OF_x_rs1         ( OF_x_rs1      ),
    .OF_x_rs2         ( OF_x_rs2      ),
    .OF_x_csr         ( OF_x_csr      )
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
    .CTRL_IF_jmp_vld  ( CTRL_IF_jmp_vld  ),
    .CTRL_IF_jmp_addr ( CTRL_IF_jmp_addr ),
    .CTRL_EX_en       ( CTRL_EX_en       )
);


endmodule