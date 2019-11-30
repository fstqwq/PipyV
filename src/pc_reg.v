`include "defines.v"

module pc_reg (
    input wire                  clk,
    input wire                  rst,

    input wire[`StallBus]       stall_state,

    input wire                  ex_b_flag_i,
    input wire[`InstAddrBus]    ex_b_target_i,

    output reg[`InstAddrBus]    pc
    
    //output reg                  ce
);

reg[`InstAddrBus] next_pc;


always @ (posedge clk) begin
//    $display("clock    %d %d", pc, next_pc);
    if (rst == `RstEnable)  begin
        pc      = `ZeroWord;
        next_pc = `ZeroWord;
//        $display("way1 %d", next_pc);
    end else if(ex_b_flag_i == `True) begin
        if(stall_state[0] == `False) begin
            pc          = ex_b_target_i;
            next_pc     = ex_b_target_i + 4;
//            $display("way2 %d", next_pc);
        end else begin
            next_pc     = ex_b_target_i;
//            $display("way3 %d", next_pc);
        end
    end else if(stall_state[0] == `False) begin
//        $display("way6 %d %d", pc, next_pc);
        pc          = next_pc;
        next_pc     = next_pc + 4;
//        $display("way6 %d %d", pc, next_pc);
    end else begin
//        $display("nothing to do, %d %d", pc, next_pc);
//        pc          <= pc;
//        next_pc     <= next_pc;
    end
//    $display("finally %d %d", pc, next_pc);
end

endmodule
