`include "defines.v"
module predictor (
    input wire      clk,
    input wire      rst,

    input wire[`InstAddrBus]    pc_if,
    output reg                  je,
    output reg[`InstAddrBus]    jdest,

    input wire[`InstAddrBus]    pc_ex,
    input wire                  is_jmp,
    input wire[`InstAddrBus]    dest,
    input wire                  jmp_res
);

reg[`PTagBus]   tag[`PIndexSize - 1:0];
reg[`InstBus]   des[`PIndexSize - 1:0];
reg[1:0]        tab[`PIndexSize - 1:0];
integer i;

always @ (posedge clk) begin
    if (rst) begin
        for (i = 0; i < `PIndexSize; i = i + 1) begin
            tag[i][`PValidBit] <= `InstInvalid; 
            tab[i] <= 2'b01;
        end
        je      <= `False;
        jdest   <= `ZeroWord;
    end else if (is_jmp && jmp_res) begin
        tag[pc_ex[`PIndexBus]] <= pc_ex[`PTagBits];
        des[pc_ex[`PIndexBus]] <= dest;
        if (tab[pc_ex[`PIndexBus]] < 2'h3) tab[pc_ex[`PIndexBus]] <= tab[pc_ex[`PIndexBus]] + 1;
    end else if (is_jmp && !jmp_res) begin
        tag[pc_ex[`PIndexBus]] <= pc_ex[`PTagBits];
        des[pc_ex[`PIndexBus]] <= dest;
        if (tab[pc_ex[`PIndexBus]] > 2'h0) tab[pc_ex[`PIndexBus]] <= tab[pc_ex[`PIndexBus]] - 1;
    end
end

always @ (*) begin
    if (rst) begin
        je    = `False;
        jdest = `ZeroWord;
    end else if (tag[pc_if[`PIndexBus]] == pc_if[`PTagBits] && tab[pc_if[`PIndexBus]][1] == 1'b1) begin
//        $display("pred : success");
        je    = `True;
        jdest = des[pc_if[`PIndexBus]];
    end else begin
        je    = `False;
        jdest = `ZeroWord;
    end
end

endmodule