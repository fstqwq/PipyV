`include "defines.v"

module if_id(
    input wire clk,
    input wire rst,

    input wire[`InstAddrBus]    if_pc,
    input wire[`InstBus]        if_inst,

    input wire                  ex_b_flag_i,

    input wire[`StallBus]       stall_state,

    output reg[`InstAddrBus]    id_pc,
    output reg[`InstBus]        id_inst
);


reg b_flag;

always @ (posedge clk) begin
    if (rst == `RstEnable) begin
        id_pc   <= `ZeroWord;
        id_inst <= `ZeroWord;
        b_flag  <= `False;
    end else if (ex_b_flag_i) begin
        id_pc   <= `ZeroWord;
        id_inst <= `ZeroWord;
        b_flag  <= (stall_state[1] == `True);
    end else if (stall_state[1] == `False) begin
        if (b_flag == `True) begin
            // during last IF stall, a branch signal is detected
            id_pc   <= `ZeroWord;
            id_inst <= `ZeroWord;
            b_flag  <= `False;
        end else begin
            id_pc   <= if_pc;
            id_inst <= if_inst;
        end
    end else if (stall_state[2] == `False) begin
        // IF stall, send NOP
        id_pc   <= `ZeroWord;
        id_inst <= `ZeroWord;
    end // else both stall, no modification needed
end

endmodule