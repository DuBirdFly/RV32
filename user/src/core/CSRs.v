`include "../inc/defines.v"

module CSRs (
    input                clk,
    input                rst,

    input                wren,
    input       [11:0]   wraddr,
    input       [31:0]   wrdata,

    // Normal CSRs
    input       [11:0]   rdaddr,
    output reg  [31:0]   CSRs_rddata,

    // Special CSRs
    // 取这三个为独特 CSRs 输出的原因: 在 <<RISC-V-Reader-Chinese-v2p1.pdf>> -P102 有说明
    // mepc, mcause, mtval 和 mstatus 这些控制寄存器只有一个副本, 处理第二个中断的时候
    // 如果软件不进行一些帮助的话，这些寄存器中的旧值会被破坏，导致数据丢失
    input                EX_mepc_vld, EX_mcause_vld, EX_mstatus_vld,
    input       [31:0]   EX_mepc,     EX_mcause,     EX_mstatus,

    output wire [31:0]   CSRs_mepc, CSRs_mstatus, CSRs_mcause
);

reg [31:0] mtvec, mepc, mcause, mie, mip, mtval, mstatus, mscratch;

// Special CSRs: always assign out regs (always read)
assign CSRs_mepc = mepc;
assign CSRs_mstatus = mstatus;
assign CSRs_mcause = mcause;

// Special CSRs: write regs
always @(posedge clk) begin
    if (rst) begin
        {mepc, mstatus, mcause} <= 'd0;
    end
    else begin
        if (EX_mepc_vld)
            mepc <= EX_mepc;
        else if (wren && wraddr == `CSRs_ADDR_MEPC)
            mepc <= wrdata;

        if (EX_mcause_vld)
            mcause  <= EX_mcause;
        else if (wren && wraddr == `CSRs_ADDR_MCAUSE)
            mcause  <= wrdata;

        if (EX_mstatus_vld)
            mstatus <= EX_mstatus;
        else if (wren && wraddr == `CSRs_ADDR_MSTATUS)
            mstatus <= wrdata;
    end
end

// Normal CSRs: write regs
always @(posedge clk) begin
    if (rst) begin
        {mtvec,  mcause, mie, mip, mtval, mscratch} <= 'd0;
    end 
    else if (wren) begin
        case (wraddr)
            `CSRs_ADDR_MTVEC:    mtvec    <= wrdata;
            `CSRs_ADDR_MCAUSE:   mcause   <= wrdata;
            `CSRs_ADDR_MIE:      mie      <= wrdata;
            `CSRs_ADDR_MIP:      mip      <= wrdata;
            `CSRs_ADDR_MTVAL:    mtval    <= wrdata;
            `CSRs_ADDR_MSCRATCH: mscratch <= wrdata;
        endcase
    end
end

// Normal CSRs: read regs
always @(posedge clk) begin
    if (rdaddr == wraddr && wren) begin
        CSRs_rddata <= wrdata;
    end
    else begin
        case (rdaddr)
            `CSRs_ADDR_MEPC:       CSRs_rddata <= mepc;
            `CSRs_ADDR_MSTATUS:    CSRs_rddata <= mstatus;
            `CSRs_ADDR_MCAUSE:     CSRs_rddata <= mcause;
            `CSRs_ADDR_MTVEC:      CSRs_rddata <= mtvec;
            `CSRs_ADDR_MCAUSE:     CSRs_rddata <= mcause;
            `CSRs_ADDR_MIE:        CSRs_rddata <= mie;
            `CSRs_ADDR_MIP:        CSRs_rddata <= mip;
            `CSRs_ADDR_MTVAL:      CSRs_rddata <= mtval;
            `CSRs_ADDR_MSCRATCH:   CSRs_rddata <= mscratch;
            default:               CSRs_rddata <= CSRs_rddata;
        endcase
    end
end

endmodule