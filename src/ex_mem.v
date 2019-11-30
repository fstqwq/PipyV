`include "defines.v"

module ex_mem (
    input wire clk,
    input wire rst,

    input wire[`RegAddrBus] ex_wd,
    input wire              ex_wreg,
    input wire[`RegBus]     ex_wdata,
    
    input wire[`MemBus]     ex_mem_addr,
    input wire[`AluOpBus]   ex_aluop,

    input wire[`StallBus]   stall_state,

    output reg[`RegAddrBus] mem_wd,
    output reg              mem_wreg,
    output reg[`RegBus]     mem_wdata,
    
    output reg[`MemBus]     mem_mem_addr,
    output reg[`AluOpBus]   mem_aluop
);

always @ (posedge clk) begin
    if (rst == `RstEnable) begin
        mem_wd          <= `NOPRegAddr;
        mem_wreg        <= `False;
        mem_wdata       <= `ZeroWord;
        mem_aluop       <= `MEM_NOP;
        mem_mem_addr    <= `ZeroWord;
    end else if (stall_state[3] == `False) begin
        mem_wd          <= ex_wd;
        mem_wreg        <= ex_wreg;
        mem_wdata       <= ex_wdata;
        mem_aluop       <= ex_aluop;
        mem_mem_addr    <= ex_mem_addr;
    end else if (stall_state[4] == `False) begin // stall[3] == `True
        mem_wd          <= `NOPRegAddr;
        mem_wreg        <= `False;
        mem_wdata       <= `ZeroWord;
        mem_aluop       <= `MEM_NOP;
        mem_mem_addr    <= `ZeroWord;
    end // else both stall, no modification needed
end

endmodule