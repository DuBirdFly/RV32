module ramGen#(
    parameter Width = 8,
    parameter Depth = 10        // 2**Depth
)(
    input                   clk,
    // read
    input                   wren,
    input       [Depth-1:0] wraddr,
    input       [Width-1:0] wrdata,
    // write
    input                   rden,
    input       [Depth-1:0] rdaddr,
    output reg  [Width-1:0] rddata
);

(*ram_style="block"*)
reg [Width-1:0] ram [(2**Depth)-1 : 0];

always @(posedge clk) begin
    if (wren) begin
        ram[wraddr] <= wrdata;
    end
end

always @(posedge clk) begin
    if (rden) begin
        rddata <= ram[rdaddr];
    end
end

endmodule