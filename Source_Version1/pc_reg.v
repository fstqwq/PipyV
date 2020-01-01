`include "defines.v"

module pc_reg (
    input wire                  clk,
    input wire                  rst,
    input wire                  rdy,

    input wire[`StallBus]       stall_state,

    input wire                  ex_b_flag_i,
    input wire[`InstAddrBus]    ex_b_target_i,

    output reg[`InstAddrBus]    pc
    
    //output reg                  ce
);

/*
integer i = 0;
always @(posedge clk) begin
    i = i + 1;
    $display("{ %d, [%h]", i, stall_state);
end
always @(negedge clk) begin
    $display("} %d, [%h]", i, stall_state);
end*/
always @ (posedge clk) begin
    if (rst == `RstEnable || rdy == `False)  begin
        pc  <= `ZeroWord;
    end else if(ex_b_flag_i == `True) begin
        pc  <= ex_b_target_i;
    end else if(stall_state[0] == `False) begin
        pc  <= pc + 4;
    end else begin
//        $display("pc_reg : stalled");
    end
end

endmodule
