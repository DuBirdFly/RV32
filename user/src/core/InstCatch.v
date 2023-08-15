// `include "../inc/defines.v"
`include "defines.v"

module InstCatch (
    input                               clk,
    input       [`InstCatchDepth-3:0]   addr,  // addr[9:0] = pc[11:2]
    // write
    // TODO: add "wren", "wrdata", jtag bin download

    // read pc register
    output wire [31:0]                  inst
);

ramGen #(
    .Width 	    ( 32        ),
    .Depth 	    ( `InstCatchDepth - 2 )
)u_ramGen(
    .clk        ( clk       ),
    .addr       ( addr      ),
    .wren       ( 1'b0      ),
    .wrdata     ( 32'd0     ),
    .rddata     ( inst      )
);

endmodule