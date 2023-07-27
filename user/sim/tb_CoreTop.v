`timescale  1ns / 1ns

`include "defines.v"

`define SIGNATURE_OUTPUT "sim/output/signature.txt"
`define ROM_DATA_FILE "sim/output/inst.data"
`define VCD_FILE "sim/output/dubirdCore_tb.vcd"

module tb_CoreTop();

parameter  SYS_CLK_FRE   = 100;                 // 100MHz
localparam PERIOD = (1000 / SYS_CLK_FRE);       // 10ns

reg clk = 0;
reg rst = 1;

always #(PERIOD/2) clk = ~clk;
always #(PERIOD*4) rst = 0;

// x3 = gp = global pointer; it's used to store test number
wire [31:0] x3 = u_CoreTop.u_Registers.regfile[3];
// x26 = 1'b1, it's used to indicate test end
wire [31:0] x26 = u_CoreTop.u_Registers.regfile[26];
// x27 = 1'b1, it's used to indicate test pass
wire [31:0] x27 = u_CoreTop.u_Registers.regfile[27];

integer r;

initial begin
    $display("~~~~~~~~~~~~~~ Simulation Start ~~~~~~~~~~~~~~");
    #200;

    // wait sim end, when x26 == 1
    wait(x26 == 32'b1)   
    #150;

    if (x27 == 32'b1) begin
        $display("TEST SIM PASS");
    end 
    else begin
        $display("TEST SIM FAIL");

        $display("x3 = %2d (global pointer, the fail test_number)\n", x3);
        
        for (r = 0; r < 32; r = r + 1)
            $display("x%2d = 0x%x", r, u_CoreTop.u_Registers.regfile[r]);
    end

end

// sim timeout, it means x26 never be 1'b1
initial begin
    #500000
    if (x26 == 32'd0)
        $display("Time Out.");
        $display("The x26 register cannot become 1 for a long time", x3);
    $finish;
end

// read mem data to instCache
initial begin
    $readmemh (`ROM_DATA_FILE, u_CoreTop.u_InstCatch.u_ramGen.ram);
end

// generate wave file, used by gtkwave or vscode-WaveTrace
initial begin
    $dumpfile(`VCD_FILE);
    $dumpvars(0, tb_CoreTop);
end

CoreTop u_CoreTop(
    .clk     ( clk  ),
    .rst     ( rst  )
);

endmodule
