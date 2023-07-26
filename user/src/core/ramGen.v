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
    output reg  [Width-1:0] rddata
);

reg [Width-1 : 0] ram [(2**Depth)-1 : 0];

always @(posedge clk) begin
    if (wren) begin
        ram[addr] <= wrdata;
    end
end

always @(posedge clk) begin
    rddata <= ram[addr];
end

endmodule