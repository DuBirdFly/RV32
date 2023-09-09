// 异步复位, 同步释放

module RstnGen(
    input           clk,
    input           asrst_n,
    output wire     srst_n
);

reg  asrst_n_d1, asrst_n_d2;

always @(posedge clk or negedge asrst_n) begin
    if (!asrst_n) begin
        asrst_n_d1 <= 1'b0;
        asrst_n_d2 <= 1'b0;
    end
    else begin
        asrst_n_d1 <= asrst_n;
        asrst_n_d2 <= asrst_n_d1;
    end
end

assign srst_n = asrst_n_d2;

endmodule