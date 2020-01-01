`include "defines.v"

module pc_reg (
    input wire                  clk,
    input wire                  rst,

    input wire[`StallBus]       stall_state,

    input wire                  ex_b_flag_i,
    input wire[`InstAddrBus]    ex_b_target_i,

    input wire                  id_b_flag_i,
    input wire[`InstAddrBus]    id_b_target_i,

    output reg[`InstAddrBus]    pc
);

always @ (posedge clk) begin
    if (rst == `RstEnable)  begin
        pc  <= `ZeroWord;
    end else if (stall_state[2] == `True) begin

    end else if(ex_b_flag_i == `True) begin
        pc  <= ex_b_target_i;
    end else if(id_b_flag_i == `True) begin
        pc  <= id_b_target_i;
    end else if (stall_state[0] == `False)begin
        pc  <= pc + 4;
    end
end

endmodule
