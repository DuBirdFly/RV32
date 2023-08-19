`timescale  1ns / 1ns

`include "defines.v"

// `define SIGNATURE_OUTPUT "sim/output/signature.txt"
`define ROM_DATA_FILE "D:/PrjWorkspace/rv32/sim/output/inst.data"
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
    #200;

    // wait sim end, when x26 == 1
    wait(x26 == 32'b1);

    #(PERIOD*(1.5));

    if (x27 == 32'b1) begin
        $display("TEST SIM PASS~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    end 
    else begin
        $display("TEST SIM FAIL");
        $display("x3(global pointer) = %2d (the fail test_number)\n", x3);
        
        for (r = 0; r < 32; r = r + 1)
            $display("x%2d = 0x%x", r, u_CoreTop.u_Registers.regfile[r]);
    end
    $finish;
end

// sim timeout, it means x26 never be 1'b1
initial begin
    #(PERIOD*2000);
    $display("Time Out.");
    $display("The x26 register cannot become 1 for a very long time");
    for (r = 0; r < 64; r = r + 1)
        // u_CoreTop.u_InstFetch.u_InstCatch.u_ramGen.ram[r]
        $display("ram[%2d] = 0x%x", r, u_CoreTop.u_InstFetch.u_InstCatch.u_ramGen.ram[r]);
    $finish;
end

// read mem data to instCache/dataCache
// reg [31:0] ram_bin [0:2048];
// reg [31:0] reg32;
initial begin
    $readmemh(`ROM_DATA_FILE, u_CoreTop.u_InstFetch.u_InstCatch.u_ramGen.ram);
    // $readmemh (`ROM_DATA_FILE, ram_bin);
    // for (r = 0; r < 1024; r = r + 1)
    //     u_CoreTop.u_InstFetch.u_InstCatch.u_ramGen.ram[r] = ram_bin[r];
    // for (r = 0; r < 1024; r = r + 1) begin
    //     reg32 = ram_bin[r+1024];
    //     u_CoreTop.u_MemoryAccess.u_DataCatch.u3_ramGen.ram[r] = reg32[31:24];
    //     u_CoreTop.u_MemoryAccess.u_DataCatch.u2_ramGen.ram[r] = reg32[23:16];
    //     u_CoreTop.u_MemoryAccess.u_DataCatch.u1_ramGen.ram[r] = reg32[15:8];
    //     u_CoreTop.u_MemoryAccess.u_DataCatch.u0_ramGen.ram[r] = reg32[7:0];
    // end
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
