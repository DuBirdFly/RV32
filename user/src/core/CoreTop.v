`include "defines.v"

module CoreTop(
    input clk,
    input rst
);

// hold
wire                            hold_if, hold_reg, hold_mem;

// IF
wire                            jump_flag;
wire    [`InstCatchDepth-1:0]   jump_addr;      // [11:0]
wire    [`InstCatchDepth-1:0]   pc;
reg     [`InstCatchDepth-1:0]   pc_d1, pc_d2;             

// InstCatch
wire    [31:0]                  inst;

// ID
wire    [4:0]                   rs1, rs2, rd, rd_d1, rd_d2;
reg     [4:0]                   rd_d1_d1, rd_d2_d1;
wire    [31:0]                  imm;
wire    [`InstIDDepth-1:0]      instID;

// Regs
wire    [31:0]                  x_rs1, x_rs2;

// EX
wire                            EX_x_rd_vld;
wire    [31:0]                  EX_x_rd;
wire    [31:0]                  MEMaddr;
wire    [3:0]                   MEMrden, MEMwren;
wire    [31:0]                  MEMwrdata;

// MEM
wire                            MEM_x_rd_vld;
wire    [31:0]                  MEM_x_rd;                

// others
reg     [2:0]                   cnt;        // 0 ~ 7

always @(posedge clk) begin
    {pc_d2, pc_d1} <= {pc_d1, pc};
    {rd_d2, rd_d1} <= {rd_d1, rd};
end

always @(posedge clk)
    if (rst) cnt <= 0;
    else cnt <= cnt + 1'b1;

assign hold_if = (cnt != 8'd0);
assign hold_mem = (cnt != 8'd4);
assign hold_reg = (cnt != 8'd5);

InstFetch u_InstFetch(
    // input
    .clk            ( clk           ),
    .rst            ( rst           ),
    .hold           ( hold_if       ),
    .jump_flag      ( jump_flag     ),
    .jump_addr      ( jump_addr     ),
    // output
    .pc             ( pc            )
);

InstCatch u_InstCatch(
    // input
    .clk            ( clk           ),
    .wren           ( 1'b0          ),
    .wraddr         ( 'd0           ),
    .wrdata         ( 'd0           ),
    .rdaddr         ( pc[`InstCatchDepth-1:2] ),
    // output
    .rddata         ( inst          )
);

InstructionDecode u_InstructionDecode(
    // input
    .clk            ( clk           ),
    .inst           ( inst          ),
    // output
    .rs1            ( rs1           ),
    .rs2            ( rs2           ),
    .rd             ( rd            ),
    .imm            ( imm           ),
    .instID         ( instID        ),
    .error          (               )
);

Registers u_Registers(
    .clk            ( clk           ),
    .hold           ( hold_reg      ),
    .rdaddr1        ( rs1           ),
    .rddata1        ( x_rs1         ),
    .rdaddr2        ( rs2           ),
    .rddata2        ( x_rs2         ),
    .wen            ( MEM_x_rd_vld  ),
    .wraddr         ( rd_d2         ),
    .wrdata         ( MEM_x_rd      )
);

Excute u_Excute(
    // input
    .clk           ( clk            ),
    .x_rs1         ( x_rs1          ),
    .x_rs2         ( x_rs2          ),
    .imm           ( imm            ),
    .instID        ( instID         ),
    .pc            ( pc_d2          ),
    .jump_flag     ( jump_flag      ),
    .jump_addr     ( jump_addr      ),
    // output
    .x_rd          ( EX_x_rd        ),
    .x_rd_vld      ( EX_x_rd_vld    ),
    .MEMaddr       ( MEMaddr        ),
    .MEMrden       ( MEMrden        ),
    .MEMwren       ( MEMwren        ),
    .MEMwrdata     ( MEMwrdata      ),
    .error         (                )
);

MemoryAccess u_MemoryAccess(
    // input
    .clk           ( clk            ),
    .hold          ( hold_mem       ),
    .EX_x_rd       ( EX_x_rd        ),
    .EX_x_rd_vld   ( EX_x_rd_vld    ),
    .rden          ( MEMrden        ),
    .wren          ( MEMwren        ),
    .wrdata        ( MEMwrdata      ),
    .addr          ( MEMaddr[11:0]  ),
    // output  
    .x_rd_vld      ( MEM_x_rd_vld   ),
    .x_rd          ( MEM_x_rd       )
);

endmodule