// `include "../inc/defines.v"
`include "defines.v"

/*
当`ICatchDepth = 12时, 2**`ICatchDepth = 4096 = 0x1000
InstCatch的空间换算
8bit * 2**`ICatchDepth = 1Byte * 4096 = 4KB
32bit * 2**(`ICatchDepth - 2) = 4Byte * 1024 = 4KB
*/

module InstCatch (
    input                               clk,
    input       [`ICatchDepth-3:0]      addr,  // addr[9:0] = pc[11:2]
    // write
    // TODO: add "wren", "wrdata", jtag bin download

    // read pc register
    output wire [31:0]                  inst
);

ramGen #(
    .Width 	    ( 32        ),
    .Depth 	    ( `ICatchDepth - 2 )
)u_ramGen(
    .clk        ( clk       ),
    .addr       ( addr      ),
    .wren       ( 1'b0      ),
    .wrdata     ( 32'd0     ),
    .rden       ( 1'b1      ),
    .rddata     ( inst      )
);

endmodule