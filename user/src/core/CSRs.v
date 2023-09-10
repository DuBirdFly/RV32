`include "../inc/defines.v"

module CSRs (
    input                clk,
    input                rst,

    input       [11:0]   rdaddr,
    output reg  [31:0]   rddata,

    input                wren,
    input       [11:0]   wraddr,
    input       [31:0]   wrdata,

    output wire          glb_int_en     // global interrupt enable
);

reg [63:0] cycle;
reg [31:0] mtvec, mepc, mcause, mie, mip, mtval, mstatus, mscratch;

assign glb_int_en = (mstatus[3] == 1'b1)? 1'b1: 1'b0;

// cycle counter
always @(posedge clk) begin
    if (rst) cycle <= 64'h0;
    else cycle <= cycle + 1'b1;
end

// write reg
always @(posedge clk) begin
    if (rst) begin
        {mtvec, mepc, mcause, mie, mip, mtval, mstatus, mscratch} <= 'd0;
    end 
    else if (wren) begin
        case (wraddr)
            `CSRs_ADDR_MTVEC: mtvec <= wrdata;
            `CSRs_ADDR_MEPC: mepc <= wrdata;
            `CSRs_ADDR_MCAUSE: mcause <= wrdata;
            `CSRs_ADDR_MIE: mie <= wrdata;
            `CSRs_ADDR_MIP: mip <= wrdata;
            `CSRs_ADDR_MTVAL: mtval <= wrdata;
            `CSRs_ADDR_MSTATUS: mstatus <= wrdata;
            `CSRs_ADDR_MSCRATCH: mscratch <= wrdata;
        endcase
    end
end

// read reg
always @(posedge clk) begin
    if (rdaddr == wraddr && wren) begin
        rddata <= wrdata;
    end
    else begin
        case (rdaddr)
            `CSRs_ADDR_CYCLE_LOW: rddata <= cycle[31:0];
            `CSRs_ADDR_CYCLE_HIGH: rddata <= cycle[63:32];
            `CSRs_ADDR_MTVEC: rddata <= mtvec;
            `CSRs_ADDR_MEPC: rddata <= mepc;
            `CSRs_ADDR_MCAUSE: rddata <= mcause;
            `CSRs_ADDR_MIE: rddata <= mie;
            `CSRs_ADDR_MIP: rddata <= mip;
            `CSRs_ADDR_MTVAL: rddata <= mtval;
            `CSRs_ADDR_MSTATUS: rddata <= mstatus;
            `CSRs_ADDR_MSCRATCH: rddata <= mscratch;
            default: rddata <= 'd0;
        endcase
    end
end


endmodule