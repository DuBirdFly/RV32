`include "defines.v"

module DataCatch (
    input                               clk,

    input       [3:0]                   wren,
    input       [31:0]                  wrdata,
    input       [31:0]                  addr,

    output wire [31:0]                  rddata

);

// 由于rv32是以1Byte为最小内存访问粒度的, 所以32bits被拆成了4个8bits (u0/1/2/3_ramGen)
// 所以每个ramGen的深度是访存深度的1/4
wire [`DataCatchDepth - 3:0] ram_addr;                    // [9:0]

// 这里最低位只到2是因为32bits被拆成了4个8bits
assign ram_addr = addr[`DataCatchDepth - 1 : 2];    // [11:2]

ramGen #(
    .Width      ( 8             ),

    .Depth      ( RAM_DEPTH     )
) u0_ramGen (
    .clk        ( clk           ),
    .addr       ( ram_addr      ),
    .wren       ( wren[0]       ),
    .wrdata     ( wrdata[7:0]   ),
    .rddata     ( rddata[7:0]   )
);

ramGen #(
    .Width      ( 8             ),
    .Depth      ( RAM_DEPTH     )
) u1_ramGen (
    .clk        ( clk           ),
    .addr       ( ram_addr      ),
    .wren       ( wren[1]       ),
    .wrdata     ( wrdata[15:8]  ),
    .rddata     ( rddata[15:8]  )
);

ramGen #(
    .Width      ( 8             ),
    .Depth      ( RAM_DEPTH     )
) u2_ramGen (
    .clk        ( clk           ),
    .addr       ( ram_addr      ),
    .wren       ( wren[2]       ),
    .wrdata     ( wrdata[23:16] ),
    .rddata     ( rddata[23:16] )
);

ramGen #(
    .Width      ( 8             ),
    .Depth      ( RAM_DEPTH     )
) u3_ramGen (
    .clk        ( clk           ),
    .addr       ( ram_addr      ),
    .wren       ( wren[3]       ),
    .wrdata     ( wrdata[31:24] ),
    .rddata     ( rddata[31:24] )
);

endmodule