`include "defines.v"

module IF (
    input wire                  clk,
    input wire                  rst,

    input wire[`InstAddrBus]    pc,
    input wire[`InstBus]        inst,
    input wire                  inst_ok,
    input wire[`InstAddrBus]    inst_pc,

    output reg[`InstAddrBus]    pc_o,
    output reg[`InstBus]        inst_o,

    output wire                 inst_fe,
    output reg[`InstAddrBus]    inst_fpc,

    output reg                  if_stall
 );

assign inst_fe = tag[inst_fpc[`IndexBus]] != inst_fpc[`TagBits];

// I-cache
reg[`TagBus] tag[`IndexSize - 1:0];
reg[`InstBus] ins[`IndexSize - 1:0];

integer i;

always @ (posedge clk) begin
    if (rst) begin
        for (i = 0; i < `IndexSize; i = i + 1) begin
            tag[i] <= `CacheNAN;
            ins[i] <= `ZeroWord;
        end
    end else begin
        if (inst_ok) begin
            tag[inst_pc[`IndexBus]] <= inst_pc[`TagBits];
            ins[inst_pc[`IndexBus]] <= inst;
        end
    end
end

always @ (*) begin
    if (rst) begin
        inst_o      = `ZeroWord;
        pc_o        = `ZeroWord;
        if_stall    = `False;
        inst_fpc    = `ZeroWord;
    end else if (tag[pc[`IndexBus]] == pc[`TagBits]) begin
        if_stall    = `False;
        inst_o      = ins[pc[`IndexBus]];
        pc_o        = pc;
        inst_fpc    = pc + 4;
    end else if (inst_ok && inst_pc == pc) begin
        if_stall    = `False;
        inst_o      = inst;
        pc_o        = pc;
        inst_fpc    = pc + 4;
    end else begin
        if_stall    = `True;
        inst_o      = `ZeroWord;
        pc_o        = `ZeroWord;
        inst_fpc    = pc;
    end
end

endmodule