`include "defines.vh"

module pc_reg(
    input wire                  clk,
    input wire                  rst,
    input wire[`StallBus]       stall,

    input wire                  id_b_flag_i,
    input wire[`InstAddrBus]    id_b_target_i,
    input wire                  ex_b_flag_i,
    input wire[`InstAddrBus]    ex_b_target_i,

    output reg[`InstAddrBus]    pc
    //output reg                  ce
);
reg[`InstAddrBus] next_pc;
reg next_jump;
reg[`InstAddrBus] target_addr;
//reg ce;
/*
always @ ( posedge clk ) begin
    if (rst == `RstEnable) begin
        ce <= `ChipsDisable;
    end else begin
        ce <= `ChipsEnable;
    end
end*/

always @ ( * ) begin
    if(rst == `RstEnable) begin
    //    next_jump = 2'b00;
        next_pc = 4'h4;
    //    pc = `ZeroWord;
    //    target_addr = `ZeroWord;
    end
    else begin
        case(next_jump)
            1'b1: begin
                //next_jump = 2'b00;
                next_pc = target_addr;
            end
            default : begin
                next_pc = pc + 4;
            end
        endcase
    end
end

always @ ( negedge clk ) begin
    if (rst == `RstEnable)  begin
        pc <= `ZeroWord;
        next_jump <= 1'b0;
        target_addr <= `ZeroWord;
    end else if(ex_b_flag_i) begin
        if(stall[0] == `NoStop) begin
            next_jump <= 1'b0;
            pc <= ex_b_target_i;
        end else begin
            next_jump <= 1'b1;
            target_addr <= ex_b_target_i;
        end
    end else if (id_b_flag_i) begin
        if(stall[0] == `NoStop) begin
            next_jump <= 1'b0;
            pc <= id_b_target_i;
        end else begin
            next_jump <= 1'b1;
            target_addr <= id_b_target_i;
        end

    //end
    end else if(stall[0] == `NoStop) begin
        pc <= next_pc;
        next_jump <= 1'b0;
        target_addr <= `ZeroWord;
    end
end
endmodule
