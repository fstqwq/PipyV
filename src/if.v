`include "defines.v"

module IF (
    input wire                  clk,
    input wire                  rst,
    input wire[`InstAddrBus]    pc,
    input wire[`InstBus]        inst,
    input wire                  inst_ok,

    output reg[`InstAddrBus]    pc_o,
    output reg[`InstBus]        inst_o,

    output reg                  if_stall
 );

always @ (posedge clk) begin
    if (rst) begin
        inst_o      <= `ZeroWord;
        pc_o        <= `ZeroWord;
        if_stall    <= `False;
    end else if (inst_ok == `True) begin
        if_stall    <= `False;
        inst_o      <= inst;
        pc_o        <= pc;
    end else begin
        if_stall    <= `True;
        inst_o      <= `ZeroWord;
        pc_o        <= `ZeroWord;
    end
end

endmodule