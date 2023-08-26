// 双端口ram的quartus介绍
// https://www.ngui.cc/el/2728307.html?action=onClick

module ramGen#(
    parameter Width = 8,
    parameter Depth = 10        // 2**Depth
)(
    input                   clk,
    input       [Depth-1:0] addr,
    // write
    input                   wren,
    input       [Width-1:0] wrdata,
    // read
    input                   rden,
    output reg  [Width-1:0] rddata
);

reg [Width-1 : 0] ram [0 : (2**Depth)-1];

always @(posedge clk) if (wren) ram[addr] <= wrdata;

always @(posedge clk) if (rden) rddata <= ram[addr];

endmodule