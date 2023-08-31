`timescale 1 ns / 1 ps

`define RstEnable 1'b0
`define RstDisable 1'b1

`define SIGNATURE_OUTPUT "sim/output/signature.txt"
`define ROM_DATA_FILE "sim/output/inst.data"
`define VCD_FILE "sim/output/soc_tb.vcd"

//`define TEST_JTAG  1

module tinyriscv_soc_tb;

    reg clk;
    reg rst;


    always #10 clk = ~clk;     // 50MHz

    wire[31:0] begin_signature = tinyriscv_soc_top_0.u_ram._ram[2];     // 也就是 ram_addr[11:8]
    wire[31:0] end_signature = tinyriscv_soc_top_0.u_ram._ram[3];       // 也就是 ram_addr[15:12]
    wire[31:0] ex_end_flag = tinyriscv_soc_top_0.u_ram._ram[4];         // 也就是 ram_addr[19:16]

    integer r;
    integer fd;

    initial begin
        clk = 0;
        rst = `RstEnable;
        $display("test running...");
        #40
        rst = `RstDisable;
        #200

        //////////////////////////////////////////////////////////////
        wait(ex_end_flag == 32'h1);  // wait sim end

        fd = $fopen(`SIGNATURE_OUTPUT);
        for (r = begin_signature; r < end_signature; r = r + 4) begin
            $fdisplay(fd, "%x", tinyriscv_soc_top_0.u_rom._rom[r[31:2]]);       // 当r为8时, r[31:2]为2, 代表第二条指令
        end
        $fclose(fd);
        ///////////////////////////////////////////////////////////////

        $finish;
    end

    // sim timeout
    initial begin
        #500000
        $display("Time Out.");
        $finish;
    end

    // read mem data
    initial begin
        $readmemh (`ROM_DATA_FILE, tinyriscv_soc_top_0.u_rom._rom);
    end

    // generate wave file, used by gtkwave
    initial begin
        $dumpfile(`VCD_FILE);
        $dumpvars(0, tinyriscv_soc_tb);
    end

    tinyriscv_soc_top tinyriscv_soc_top_0(
        .clk(clk),
        .rst(rst)
    );

endmodule
