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


// I-cache
reg[`TagBus] tag[`IndexSize - 1:0];
reg[`InstBus] ins[`IndexSize - 1:0];

assign inst_fe = tag[inst_fpc[`IndexBus]] != inst_fpc[`TagBits] & ~inst_ok;

integer i;

always @ (posedge clk) begin
    if (rst) begin
        for (i = 0; i < `IndexSize; i = i + 1) begin
            tag[i][`ValidBit] <= `CacheInvalid;
        end
        inst_fpc    <= `ZeroWord;
    end else begin
        if (inst_ok) begin
            tag[inst_pc[`IndexBus]] <= inst_pc[`TagBits];
            ins[inst_pc[`IndexBus]] <= inst;
            inst_fpc                <= pc + 4;
        end else begin
            inst_fpc                <= pc;
        end
    end
end

always @ (*) begin
    if (rst) begin
        inst_o      = `ZeroWord;
        pc_o        = `ZeroWord;
        if_stall    = `False;
    end else if (tag[pc[`IndexBus]] == pc[`TagBits]) begin
        if_stall    = `False;
        inst_o      = ins[pc[`IndexBus]];
        pc_o        = pc;
    end else if (inst_ok && inst_pc == pc) begin
        if_stall    = `False;
        inst_o      = inst;
        pc_o        = pc;
    end else begin
        if_stall    = `True;
        inst_o      = `ZeroWord;
        pc_o        = `ZeroWord;
    end
end

endmodule
