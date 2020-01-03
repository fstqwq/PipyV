`include "defines.v"

module pc_reg (
    input wire                  clk,
    input wire                  rst,

    input wire[`StallBus]       stall_state,

    input wire                  ex_b_flag_i,
    input wire[`InstAddrBus]    ex_b_target_i,

//    input wire                  id_b_flag_i,
//    input wire[`InstAddrBus]    id_b_target_i,

    input wire                  je,
    input wire[`InstAddrBus]    jdest,

    output reg[`InstAddrBus]    pc,
    output reg                  jmp
);

always @ (posedge clk) begin
    if (rst == `RstEnable)  begin
        pc  <= `ZeroWord;
        jmp <= `False;
    end else if (stall_state[2] == `True) begin

    end else if(ex_b_flag_i == `True) begin
        pc  <= ex_b_target_i;
        jmp <= `False;
/*    end else if(id_b_flag_i == `True) begin
        pc  <= id_b_target_i;
        jmp <= `False;*/
    end else if (stall_state[0] == `True) begin

    end else if (je == `True) begin
        pc  <= jdest;
        jmp <= `True;
    end else begin
        pc  <= pc + 4;
        jmp <= `False;
    end
end

endmodule
