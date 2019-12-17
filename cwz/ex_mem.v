`include "defines.vh"
module ex_mem (
    input wire                  clk,
    input wire                  rst,

    input wire[`RegAddrBus]     ex_wd,
    input wire                  ex_wreg,
    input wire[`RegBus]         ex_wdata,

    input wire[`MemBus]         ex_mem_addr,
    input wire[`AluOpBus]       ex_aluop,

    input wire[`StallBus]       stall,


    output reg[`RegAddrBus]     mem_wd,
    output reg                  mem_wreg,
    output reg[`RegBus]         mem_wdata,
    output reg[`MemBus]         mem_mem_addr,
    output reg[`AluOpBus]       mem_aluop
);

always @ ( posedge clk ) begin
    if(rst == `RstEnable) begin
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `ZeroWord;
        mem_aluop <= `ME_NOP_OP;
        mem_mem_addr <= `ZeroWord;
    end else if (stall[3] == `Stop && stall[4] == `NoStop) begin
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `ZeroWord;
        mem_aluop <= `ME_NOP_OP;
        mem_mem_addr <= `ZeroWord;
    end else if(stall[3] == `NoStop) begin
        mem_wd <= ex_wd;
        mem_wreg <= ex_wreg;
        mem_wdata <= ex_wdata;
        mem_mem_addr <= ex_mem_addr;
        mem_aluop <= ex_aluop;
    end
end

endmodule // ex_mem
