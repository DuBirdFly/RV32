`timescale  1ns / 1ns

`include "defines.v"

`define SIGNATURE_OUTPUT "sim/output/signature.txt"
`define ROM_DATA_FILE "sim/output/inst.data"
`define VCD_FILE "sim/output/dubirdCore_tb.vcd"

module tb_CoreTop();

///////////////////////////////////////////////////////////////////
parameter  SYS_CLK_FRE   = 100;                 // 100MHz
localparam PERIOD = (1000 / SYS_CLK_FRE);       // 10ns

reg clk = 0;
reg rst = 1;

always #(PERIOD/2) clk = ~clk;
always #(PERIOD*4) rst = 0;

///////////////////////////////////////////////////////////////////
wire [31:0] begin_signature = u_CoreTop.u_MemAccess.u_ramGen.ram[2];
wire [31:0] end_signature = u_CoreTop.u_MemAccess.u_ramGen.ram[3];
wire [31:0] ex_end_flag = u_CoreTop.u_MemAccess.u_ramGen.ram[4];

/*
1. ram of ICatch -- (最小粒度: 32bit)
    [0x0000 ~ 0x0ffc] *  8bit
    [0x0000 ~ 0x03ff] * 32bit
    [     0 ~   1023] * 32bit
2. ram of <tohost>
    [0x1000 ~ 0x1100] *  8bit
3. ram of <fromhost>
    [0x1100 ~ 0x1fff] *  8bit
3. ram of DCatch -- (最小粒度: 8bit)
    [0x2000 ~ 0x2ffc]*  8bit
    [0x0800 ~ 0x0bff]* 32bit
    [  2048 ~   3071]* 32bit
4. ram of signature -- (最小粒度: 32bit)
    0x10000008 * 32bit : begin_signature = 0x2000 (I-ADD-01.elf.objdump)
    0x1000000c * 32bit : end_signature   = 0x2090 (I-ADD-01.elf.objdump)
    0x10000010 * 32bit : ex_end_flag
*/
reg [31:0] ram_bin [0:3071];
reg [31:0] reg32;

reg [7:0] reg0, reg1, reg2, reg3;

integer r;
integer fd;

initial begin
    // =================================================
    $readmemh (`ROM_DATA_FILE, ram_bin);
    // ram of ICatch 
    for (r = 0; r < 1024; r = r + 1) begin
        reg32 = ram_bin[r];
        u_CoreTop.u_InstFetch.u_InstCatch.u_ramGen.ram[r] =  reg32;
    end
    //* ram of <tohost> + <fromhost>
    for (r = 1024; r < 1024 + 1024; r = r + 1) begin
        u_CoreTop.u_MemAccess.u_DataCatch.u3_ramGen.ram[r-1024] = 8'd0;
        u_CoreTop.u_MemAccess.u_DataCatch.u2_ramGen.ram[r-1024] = 8'd0;
        u_CoreTop.u_MemAccess.u_DataCatch.u1_ramGen.ram[r-1024] = 8'd0;
        u_CoreTop.u_MemAccess.u_DataCatch.u0_ramGen.ram[r-1024] = 8'd0;
    end
    // ram of DCatch
    for (r = 2048; r < 2048 + 1024; r = r + 1) begin
        reg32 = ram_bin[r];
        u_CoreTop.u_MemAccess.u_DataCatch.u3_ramGen.ram[r-1024] = reg32[31:24];
        u_CoreTop.u_MemAccess.u_DataCatch.u2_ramGen.ram[r-1024] = reg32[23:16];
        u_CoreTop.u_MemAccess.u_DataCatch.u1_ramGen.ram[r-1024] = reg32[15:8];
        u_CoreTop.u_MemAccess.u_DataCatch.u0_ramGen.ram[r-1024] = reg32[7:0];
    end
    // ram of signature
    for (r = 0; r < 16; r = r + 1) begin
        reg32 = 32'h0;
        u_CoreTop.u_MemAccess.u_ramGen.ram[r] = reg32;
    end
    //=================================================
    #200;
    //=================================================
    wait(ex_end_flag == 32'h1);  // wait sim end
    // begin_signature = 0x2000 (I-ADD-01.elf.objdump)
    // end_signature   = 0x2090 (I-ADD-01.elf.objdump)
    // `DCatchStartAddr = 2**12 = 0x1000
    fd = $fopen(`SIGNATURE_OUTPUT);
    for (r = (begin_signature-`DCatchStartAddr)/4; r < (end_signature-`DCatchStartAddr)/4; r = r + 1) begin
        reg3 = u_CoreTop.u_MemAccess.u_DataCatch.u3_ramGen.ram[r];
        reg2 = u_CoreTop.u_MemAccess.u_DataCatch.u2_ramGen.ram[r];
        reg1 = u_CoreTop.u_MemAccess.u_DataCatch.u1_ramGen.ram[r];
        reg0 = u_CoreTop.u_MemAccess.u_DataCatch.u0_ramGen.ram[r];
        $fdisplay(fd, "%x", {reg3, reg2, reg1, reg0});
    end
    $fclose(fd);
    //=================================================
    $display("TEST SIM Finished!!!!!!");
    $finish;
end

///////////////////////////////////////////////////////////////////
initial begin
    #(PERIOD*1024);
    // begin_signature = 0x2000 (I-ADD-01.elf.objdump)
    // end_signature   = 0x2090 (I-ADD-01.elf.objdump)
    // `DCatchStartAddr = 2**12 = 0x1000
    fd = $fopen(`SIGNATURE_OUTPUT);
    for (r = (begin_signature-`DCatchStartAddr)/4; r < (end_signature-`DCatchStartAddr)/4; r = r + 1) begin
        reg3 = u_CoreTop.u_MemAccess.u_DataCatch.u3_ramGen.ram[r];
        reg2 = u_CoreTop.u_MemAccess.u_DataCatch.u2_ramGen.ram[r];
        reg1 = u_CoreTop.u_MemAccess.u_DataCatch.u1_ramGen.ram[r];
        reg0 = u_CoreTop.u_MemAccess.u_DataCatch.u0_ramGen.ram[r];
        print("%x", {reg3, reg2, reg1, reg0});
    end
    $fclose(fd);
    $display("TEST SIM Time Out!!!!!!");
    $finish;
end

///////////////////////////////////////////////////////////////////
initial begin
    $dumpfile(`VCD_FILE);
    $dumpvars(0, tb_CoreTop);
end

///////////////////////////////////////////////////////////////////
CoreTop u_CoreTop(
    .clk     ( clk  ),
    .rst     ( rst  )
);

endmodule
