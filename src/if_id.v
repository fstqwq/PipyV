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
/*
integer i;
always @ (posedge clk) begin
    if (rst) begin
        i <= 0;
    end else begin
        $display(i);
        i <= i + 1;
    end
end
*/
always @ (posedge clk) begin
    if (rst == `RstEnable) begin
        id_inst <= `ZeroWord;
        id_pc   <= `ZeroWord;
//        b_flag  <= `False;
    end else if (ex_b_flag_i) begin
    //    $display("if_id : b_flag is on");
        id_inst <= `ZeroWord;
        id_pc   <= `ZeroWord;
    end else if (stall_state[1] == `False) begin
        id_inst <= if_inst;
        id_pc   <= if_pc;
//        $display("if_id : %h %h", if_pc, if_inst);
    end else if (stall_state[2] == `False) begin
        id_inst <= `ZeroWord;
        id_pc   <= `ZeroWord;
    end else begin
//        $display("if_id : Both stalled");
    end// else both stall, no modification needed
end

endmodule