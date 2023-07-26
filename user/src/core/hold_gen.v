module hold_gen(
    input           clk,
    input           rst,
    output  wire    hold_if,
    output  wire    hold_mem,
    output  wire    hold_reg
);

reg     [2:0]                   cnt;        // 0 ~ 7

always @(posedge clk)
    if (rst) cnt <= 0;
    else cnt <= cnt + 1'b1;

assign hold_if = (cnt != 8'd0);
assign hold_mem = (cnt != 8'd4);
assign hold_reg = (cnt != 8'd5);

endmodule