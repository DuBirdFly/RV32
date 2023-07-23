`include "defines.v"

module DataCatch (
    input                               clk,


    input       [3:0]                   rden,
    input       [3:0]                   wren,
    input       [31:0]                  wrdata,
    input       [`DataCatchDepth - 1:0] addr,       // [11:0]

    output wire [31:0]                  rddata

);

ramGen #(
    .Width      ( 8             ),
    // 由于rv32是以1Byte为最小内存访问粒度的, 所以32bits被拆成了4个8bits (u0/1/2/3_ramGen)
    // 所以每个ramGen的深度是访存深度的1/4
    .Depth      ( `DataCatchDepth - 2 )
) u0_ramGen (
    .clk        ( clk           ),
    .wren       ( wren[0]       ),
    // 这里最低位只到2也是因为32bits被拆成了4个8bits
    .wraddr     ( addr[`DataCatchDepth - 1 : 2] ),
    .wrdata     ( wrdata[7:0]   ),
    .rden       ( rden[0]       ),
    .rdaddr     ( addr          ),
    .rddata     ( rddata[7:0]   )
);

ramGen #(
    .Width      ( 8             ),
    .Depth      ( `DataCatchDepth - 2 )
) u1_ramGen (
    .clk        ( clk           ),
    .wren       ( wren[1]       ),
    .wraddr     ( addr[`DataCatchDepth - 1 : 2] ),
    .wrdata     ( wrdata[15:8]   ),
    .rden       ( rden[1]       ),
    .rdaddr     ( addr          ),
    .rddata     ( rddata[15:8]   )
);

ramGen #(
    .Width      ( 8             ),
    .Depth      ( `DataCatchDepth - 2 )
) u2_ramGen (
    .clk        ( clk           ),
    .wren       ( wren[2]       ),
    .wraddr     ( addr[`DataCatchDepth - 1 : 2] ),
    .wrdata     ( wrdata[23:16]   ),
    .rden       ( rden[2]       ),
    .rdaddr     ( addr          ),
    .rddata     ( rddata[23:16]   )
);

ramGen #(
    .Width      ( 8             ),
    .Depth      ( `DataCatchDepth - 2 )
) u3_ramGen (
    .clk        ( clk           ),
    .wren       ( wren[3]       ),
    .wraddr     ( addr[`DataCatchDepth - 1 : 2] ),
    .wrdata     ( wrdata[31:24]   ),
    .rden       ( rden[3]       ),
    .rdaddr     ( addr          ),
    .rddata     ( rddata[31:24]   )
);

endmodule