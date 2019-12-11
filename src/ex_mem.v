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
    output reg[`AluOpBus]   mem_aluop,
    
    output reg inquiry_o
);
/*
reg[`RegAddrBus] last_wd;
reg last_wreg;
reg[`RegBus] last_wdata;
reg[`MemBus] last_addr;
reg[`AluOpBus]   last_aluop;
*/
always @ (posedge clk) begin
    if (rst == `RstEnable) begin
        mem_wd          <= `NOPRegAddr;
        mem_wreg        <= `False;
        mem_wdata       <= `ZeroWord;
        mem_aluop       <= `MEM_NOP;
        mem_mem_addr    <= `ZeroWord;
        inquiry_o       <= 1'b0;
    end else if (stall_state[4] == `False) begin
/*        if (last_wd == ex_wd &&
            last_wreg == ex_wreg &&
            last_wdata == ex_wdata &&
            last_addr == ex_mem_addr &&
            last_aluop == ex_aluop) begin
            mem_wd          <= `NOPRegAddr;
            mem_wreg        <= `False;
            mem_wdata       <= `ZeroWord;
            mem_aluop       <= `MEM_NOP;
            mem_mem_addr    <= `ZeroWord;
        end else begin*/
            mem_wd          <= ex_wd;
            mem_wreg        <= ex_wreg;
            mem_wdata       <= ex_wdata;
            mem_aluop       <= ex_aluop;
            mem_mem_addr    <= ex_mem_addr;
            inquiry_o       <= inquiry_o ^ (ex_aluop != `MEM_NOP);
        /*
            last_wd         <= ex_wd;
            last_wreg       <= ex_wreg;
            last_wdata      <= ex_wdata;
            last_aluop      <= ex_aluop;
            last_addr       <= ex_mem_addr;
        end*/
    end
end

endmodule