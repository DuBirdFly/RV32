// `include "../inc/defines.v"
`include "defines.v"

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

InstructionDecode u_InstructionDecode(
    .inst           ( IF_inst     ),
    .ID_opcode      ( ID_opcode   ),
    // regs_addr and regs addr vld
    .ID_rs1         ( ID_rs1      ),
    .ID_rs2         ( ID_rs2      ),
    .ID_rd          ( ID_rd       ),
    .ID_rs1_vld     ( ID_rs1_vld  ),
    .ID_rs2_vld     ( ID_rs2_vld  ),
    .ID_rd_vld      ( ID_rd_vld   ),
    //
    .ID_imm         ( ID_imm      ),
    .ID_instID      ( ID_instID   ),
    .ID_jmp_vld     ( ID_jmp_vld  )
);

// Signal Delay ------------------------------------------
reg [31:0]                  IF_pc_d1;
reg [6:0]                   ID_opcode_d1;
reg [4:0]                   ID_rs1_d1, ID_rs2_d1;
reg [4:0]                   ID_rd_d1, ID_rd_d2, ID_rd_d3;
reg [31:0]                  ID_imm_d1;
reg [`InstIDDepth-1:0]      ID_instID_d1;

always @(posedge clk) begin
    IF_pc_d1 <= IF_pc;
    ID_opcode_d1 <= ID_opcode;
    {ID_rs1_d1, ID_rs2_d1} <= {ID_rs1, ID_rs2};
    {ID_rd_d3, ID_rd_d2, ID_rd_d1} <= {ID_rd_d2, ID_rd_d1, ID_rd};
    ID_imm_d1 <= ID_imm;
    ID_instID_d1 <= ID_instID;
end

// Register File -----------------------------------------
wire [4:0]                  REGS_rdaddr1, REGS_rdaddr2;
wire                        REGS_wen;
wire [4:0]                  REGS_wraddr;
wire [31:0]                 REGS_wrdata;

wire [31:0]                 REGS_rddata1;
wire [31:0]                 REGS_rddata2;

assign REGS_rdaddr1 = ID_rs1_d1;
assign REGS_rdaddr2 = ID_rs2_d1;

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

wire [4:0]                  EX_rd;
wire                        EX_jmp_vld;
wire [31:0]                 EX_jmp_addr;
wire                        EX_x_rd_vld;
wire [31:0]                 EX_x_rd;
wire [31:0]                 EX_MEMaddr;
wire [3:0]                  EX_MEMrden, EX_MEMwren;
wire                        EX_MEMrden_SEXT;
wire [31:0]                 EX_MEMwrdata;

assign EX_rd = ID_rd_d2;

Execute u_Execute(
    .clk              ( clk           ),
    .inst_vld         ( inst_vld_EX   ),
    .x_rs1            ( OF_x_rs1      ),
    .x_rs2            ( OF_x_rs2      ),
    .imm              ( ID_imm_d1     ),
    .instID           ( ID_instID_d1  ),
    .pc               ( IF_pc_d1      ),
    .EX_jmp_vld       ( EX_jmp_vld    ),
    .EX_jmp_addr      ( EX_jmp_addr   ),
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

MemoryAccess u_MemoryAccess(
    .clk              ( clk           ),
    .EX_x_rd_vld      ( EX_x_rd_vld   ),
    .EX_x_rd          ( EX_x_rd       ),
    .rden             ( EX_MEMrden    ),
    .rden_SEXT        ( EX_MEMrden_SEXT ),
    .wren             ( EX_MEMwren    ),
    .wrdata           ( EX_MEMwrdata  ),
    .addr             ( EX_MEMaddr    ),
    .MEM_x_rd_vld     ( MEM_x_rd_vld  ),
    .MEM_x_rd         ( MEM_x_rd      )
);

// Write Back ---------------------------------------------
assign REGS_wen = MEM_x_rd_vld;
assign REGS_wraddr = ID_rd_d3;
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
    .ID_rd_d1         ( ID_rd_d1      ),
    .ID_opcode_d1     ( ID_opcode_d1  ),
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