`include "defines.v"

module id_ex (
    input wire clk,
    input wire rst,
    input wire[`AluSelBus]      id_alusel,
    input wire[`AluOpBus]       id_aluop,
    input wire[`RegBus]         id_reg1,
    input wire[`RegBus]         id_reg2,
    input wire[`RegAddrBus]     id_wd,
    input wire                  id_wreg,
    input wire[`InstAddrBus]    id_pc,
    input wire[`InstAddrBus]    offset_i,

    input wire                  ex_b_flag_i,
    
    input wire[`StallBus]       stall_state,

    output reg[`AluSelBus]     ex_alusel,
    output reg[`AluOpBus]      ex_aluop,
    output reg[`RegBus]        ex_reg1,
    output reg[`RegBus]        ex_reg2,
    output reg[`RegAddrBus]    ex_wd,
    output reg[`InstAddrBus]   ex_pc,
    output reg                 ex_wreg,
    output reg[`InstAddrBus]   offset_o
);

always @ (posedge clk) begin
    if (rst == `RstEnable) begin
        ex_aluop    <= `EX_NOP;
        ex_alusel   <= `EX_RES_NOP;
        ex_reg1     <= `ZeroWord;
        ex_reg2     <= `ZeroWord;
        ex_wd       <= `NOPRegAddr;
        ex_wreg     <= `False;
        ex_pc       <= `ZeroWord;
        offset_o    <= `ZeroWord;
    end else if (stall_state[3] == `True) begin

    end else if (ex_b_flag_i == `True) begin
        ex_aluop    <= `EX_NOP;
        ex_alusel   <= `EX_RES_NOP;
        ex_reg1     <= `ZeroWord;
        ex_reg2     <= `ZeroWord;
        ex_wd       <= `NOPRegAddr;
        ex_wreg     <= `False;
        ex_pc       <= `ZeroWord;
        offset_o    <= `ZeroWord;
   end else if (stall_state[2] == `False) begin
            ex_aluop    <= id_aluop;
            ex_alusel   <= id_alusel;
            ex_reg1     <= id_reg1;
            ex_reg2     <= id_reg2;
            ex_wd       <= id_wd;
            ex_wreg     <= id_wreg;
            ex_pc       <= id_pc;
            offset_o    <= offset_i;
    end else begin
        ex_aluop    <= `EX_NOP;
        ex_alusel   <= `EX_RES_NOP;
        ex_reg1     <= `ZeroWord;
        ex_reg2     <= `ZeroWord;
        ex_wd       <= `NOPRegAddr;
        ex_wreg     <= `False;
        ex_pc       <= `ZeroWord;
        offset_o    <= `ZeroWord;
    end
end
endmodule