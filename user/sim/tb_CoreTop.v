`timescale  1ns / 1ns
module tb_CoreTop();

parameter  SYS_CLK_FRE   = 100;                 // 100MHz
localparam PERIOD = (1000 / SYS_CLK_FRE);       // 10ns

reg sys_clk = 0;
reg sys_rst = 1;

always #(PERIOD/2) sys_clk = ~sys_clk;
always #(PERIOD*4) sys_rst = 0;

CoreTop u_CoreTop(
    .clk     ( sys_clk  ),
    .rst     ( sys_rst  )
);

initial begin
    $dumpfile("tb_CoreTop.vcd");
    $dumpvars(0, tb_CoreTop);
    #700;
    $finish;
end

endmodule
