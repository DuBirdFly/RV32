/**********************************************************************************
ChatGPT-4的问答:
Q: 在RISC-V的32位版本RV32中, 有指令sw(store word), 
   其表达式为Mem[X[rs1] + sext(offset)] = x[rs2][31:0], 
   其中X[rs1] + sext(offset)的结果一定是4的倍数吗
A: 是的，RISC-V架构中的指令sw是用来存储word的，一个word在这里等于4个字节，
   这就是为什么X[rs1] + sext(offset)的结果需要是4的倍数。
   它需要对齐于4字节，也就是一个word的边界，以保证数据的地址正确性和访问性能。
   如果地址不是4的倍数，那么并不能正确地保存一个word（也就是32位数据），并可能导致性能下降和数据错误。
   因此，在RV32中，对存储和载入的地址有这样的多字节对齐要求。

Q: sh(store halfword)指令, 也就是M[X[rs1] + sext(offset)] = x[rs2][15:0]也是这样的吗
A: 不完全一样。sh指令用于存储halfword，即16位（或者说2个字节）的数据。
   因此，对于这个指令，X[rs1] + sext(offset)的结果需要是2的倍数，而不是4的倍数。
   这是因为halfword的长度为2个字节，因此它的地址需要对齐到2字节边界。
   如果地址不是2的倍数，那么就无法正确存储一个halfword，可能会导致数据错误或性能下降。
   所以，在使用sh指令时，必须确保所使用的地址是2的倍数。
**********************************************************************************/

// `include "../inc/defines.v"
`include "defines.v"

module MemAccess(
    input               clk,

    input       [4:0]   rd,
    input       [31:0]  x_rd,
    input               rd_vld,

    input       [31:0]  addr,
    input               rden_SEXT,
    input       [3:0]   rden,
    input       [3:0]   wren,
    input       [31:0]  wrdata,

    output reg  [4:0]   MEM_rd,             // 打1拍
    output reg          MEM_rd_vld,         // 打1拍
    output reg  [31:0]  MEM_x_rd            // 组合逻辑 (从Catch中读出的数据后组合逻辑拼接)
);

wire [ 3:0] DCatch_wren, DCatch_rden;
wire [31:0] DCatch_rdata;

assign DCatch_wren = addr[28] ? 4'b0000 : wren;
assign DCatch_rden = addr[28] ? 4'b0000 : rden;

DataCatch u_DataCatch(      
    .clk        ( clk           ),
    .addr       ( addr          ),
    .wren       ( DCatch_wren   ),
    .wrdata     ( wrdata        ),
    .rden       ( DCatch_rden   ),
    .rddata     ( DCatch_rdata  )
);

reg rden_SEXT_d1;
reg [31:0] EX_x_rd_d1;
reg [3:0] DCatch_rden_d1;

// 打拍器
always @(posedge clk) begin
    MEM_rd <= rd;
    MEM_rd_vld <= rd_vld;
    rden_SEXT_d1 <= rden_SEXT;
    EX_x_rd_d1 <= x_rd;
    DCatch_rden_d1 <= DCatch_rden;
end

// 组合逻辑(从Catch中读出的数据后组合逻辑拼接)
always @(*) begin
    if (rden_SEXT_d1) begin
        case (DCatch_rden_d1)
            4'b0001: MEM_x_rd = {{24{DCatch_rdata[7]}},  DCatch_rdata[7:0]};
            4'b0010: MEM_x_rd = {{24{DCatch_rdata[15]}}, DCatch_rdata[15:8]};
            4'b0100: MEM_x_rd = {{24{DCatch_rdata[23]}}, DCatch_rdata[23:16]};
            4'b1000: MEM_x_rd = {{24{DCatch_rdata[31]}}, DCatch_rdata[31:24]};
            4'b0011: MEM_x_rd = {{16{DCatch_rdata[15]}}, DCatch_rdata[15:0]};
            4'b1100: MEM_x_rd = {{16{DCatch_rdata[31]}}, DCatch_rdata[31:16]};
            4'b1111: MEM_x_rd = DCatch_rdata;
            default: MEM_x_rd = EX_x_rd_d1;
        endcase
    end
    else begin
        case (DCatch_rden_d1)
            4'b0001: MEM_x_rd = {{24{1'b0}}, DCatch_rdata[7:0]};
            4'b0010: MEM_x_rd = {{24{1'b0}}, DCatch_rdata[15:8]};
            4'b0100: MEM_x_rd = {{24{1'b0}}, DCatch_rdata[23:16]};
            4'b1000: MEM_x_rd = {{24{1'b0}}, DCatch_rdata[31:24]};
            4'b0011: MEM_x_rd = {{16{1'b0}}, DCatch_rdata[15:0]};
            4'b1100: MEM_x_rd = {{16{1'b0}}, DCatch_rdata[31:16]};
            4'b1111: MEM_x_rd = DCatch_rdata;
            default: MEM_x_rd = EX_x_rd_d1;
        endcase
    end
end

endmodule