`include "defines.v"

module InstCatch (
    input                               clk,
    // write, jtag bin download
    input                               wren,
    input       [`InstCatchDepth-1:0]   wraddr,
    input       [31:0]                  wrdata,
    // read pc register
    input       [`InstCatchDepth-1:0]   rdaddr,
    output wire [31:0]                  rddata
);

ramGen #(
    .Width 	    ( 32        ),
    .Depth 	    ( `InstCatchDepth )
)u_ramGen(
	.clk    	( clk       ),
	.wren   	( wren      ),
	.wraddr 	( wraddr    ),
	.wrdata 	( wrdata    ), 
	.rden   	( 1'b1      ),
	.rdaddr 	( rdaddr    ),
	.rddata 	( rddata    )
);


endmodule