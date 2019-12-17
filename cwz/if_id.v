`include "defines.vh"
module if_id (
    input wire                      clk,
    input wire                      rst,
    input wire [`InstAddrBus]       if_pc,
    input wire [`InstBus]           if_inst,
    input wire[`StallBus]           stall,

    input wire                      id_b_flag_i,
    input wire                      ex_b_flag_i,

    output reg[`InstAddrBus]        id_pc,
    output reg[`InstBus]            id_inst
);

reg next_jump;

always @ ( posedge clk ) begin
    if (rst == `RstEnable) begin
        id_pc <= `ZeroWord;
        id_inst <= `ZeroWord;
        next_jump <= 1'b0;
    end else if (id_b_flag_i || ex_b_flag_i) begin
        if(stall[1] == `Stop && stall[2] == `NoStop) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
            next_jump <= 1'b1;
        end else if(stall[1] == `Stop) begin
            next_jump <= 1'b1;
        //end else if (stall[1] == `NoStop) begin
        end else begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
            next_jump <= 1'b0;
        //end else begin
        //    next_jump <= 1'b1;
        end
    end else if (stall[1] == `Stop && stall[2] == `NoStop) begin
        id_pc <= `ZeroWord;
        id_inst <= `ZeroWord;
    end else if(stall[1] == `NoStop) begin
        if(next_jump) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
            next_jump <= 1'b0;
        end else begin
            id_pc <= if_pc;
            id_inst <= if_inst;
        end
    end
end
endmodule // if_id
