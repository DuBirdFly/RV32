`include "../inc/defines.v"

/*
由于rv32是以1Byte为最小内存访问粒度的, 所以32bits被拆成了4个8bits (u0/1/2/3_ramGen)
所以每个ramGen的深度是访存深度的1/4

以 `DCatchDepth = 12为例
期望的 DCatch 的存储空间为 2^12 * 8bit = 0x1000 * 8bit = 4KB
但由于有时需要访问最多 32bit 的数据
所以实际的存储空间为 (2^(12-2)) * 32bit = 0d1000 * 32bit = 4KB
*/

module DataCatch #(
    parameter RAM_DEPTH = `DCatchDepth - 2
)(
    input                               clk,
    input       [RAM_DEPTH - 1:0]       addr,

    input       [3:0]                   wren,
    input       [31:0]                  wrdata,

    input       [3:0]                   rden,
    output wire [31:0]                  rddata

);

ramGen #(
    .Width      ( 8             ),
    .Depth      ( RAM_DEPTH     )
) u0_ramGen (
    .clk        ( clk           ),
    .addr       ( addr          ),
    .wren       ( wren[0]       ),
    .wrdata     ( wrdata[7:0]   ),
    .rden       ( rden[0]       ),
    .rddata     ( rddata[7:0]   )
);

ramGen #(
    .Width      ( 8             ),
    .Depth      ( RAM_DEPTH     )
) u1_ramGen (
    .clk        ( clk           ),
    .addr       ( addr          ),
    .wren       ( wren[1]       ),
    .wrdata     ( wrdata[15:8]  ),
    .rden       ( rden[1]       ),
    .rddata     ( rddata[15:8]  )
);

ramGen #(
    .Width      ( 8             ),
    .Depth      ( RAM_DEPTH     )
) u2_ramGen (
    .clk        ( clk           ),
    .addr       ( addr          ),
    .wren       ( wren[2]       ),
    .wrdata     ( wrdata[23:16] ),
    .rden       ( rden[2]       ),
    .rddata     ( rddata[23:16] )
);

ramGen #(
    .Width      ( 8             ),
    .Depth      ( RAM_DEPTH     )
) u3_ramGen (
    .clk        ( clk           ),
    .addr       ( addr          ),
    .wren       ( wren[3]       ),
    .wrdata     ( wrdata[31:24] ),
    .rden       ( rden[3]       ),
    .rddata     ( rddata[31:24] )
);

endmodule