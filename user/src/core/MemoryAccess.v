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

`include "defines.v"

module MemoryAccess(
    input               clk,

    input               EX_x_rd_vld,
    input       [31:0]  EX_x_rd,

    input       [3:0]   rden,
    input       [3:0]   wren,
    input       [31:0]  wrdata,
    input       [11:0]  addr,

    output reg          x_rd_vld,           // 时序逻辑 (打1拍)
    output reg  [31:0]  x_rd                // 组合逻辑 (从Catch中读出的数据后组合逻辑拼接)

);

reg [31:0] EX_x_rd_d1;                      // EX_x_rd打一拍
reg [3:0] rden_d1;                          // rden打一拍

wire [31:0] oDataCatch;                     // output of DataCatch

// 组合逻辑(从Catch中读出的数据后组合逻辑拼接)
always @(*) begin
    case (rden_d1)
        4'b0001: x_rd = {24'h000000, oDataCatch[7:0]};
        4'b0010: x_rd = {24'h000000, oDataCatch[15:8]};
        4'b0100: x_rd = {24'h000000, oDataCatch[23:16]};
        4'b1000: x_rd = {24'h000000, oDataCatch[31:24]};
        4'b0011: x_rd = {16'h0000, oDataCatch[15:0]};
        4'b1100: x_rd = {16'h0000, oDataCatch[31:16]};
        4'b1111: x_rd = oDataCatch;
        default: x_rd = EX_x_rd_d1;
    endcase
end

// 打拍器
always @(posedge clk) begin
    x_rd_vld <= EX_x_rd_vld;
    EX_x_rd_d1 <= EX_x_rd;
    rden_d1 <= rden;
end

DataCatch u_DataCatch(      
    .clk        ( clk           ),
    .rden       ( rden          ),
    .wren       ( wren          ),
    .wrdata     ( wrdata        ),
    .addr       ( addr[11:2]    ),
    .rddata     ( oDataCatch    )
);


endmodule