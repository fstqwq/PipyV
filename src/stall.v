`include "defines.v"

module stall (
    input wire rst,
    input wire rdy,
    input wire if_stall,
    input wire id_stall,
//    input wire ex_stall,
    input wire mem_stall,
//    input wire mctl_stall,

    output reg[`StallBus] stall_state
);

always @ (*) begin
    if (rst == `RstEnable) begin
        stall_state = `NoStall;
    end else if (rdy == `False) begin
        stall_state = `AllStall;
    end else if (mem_stall == `True) begin
        stall_state = `MemStall;
//    end else if (ex_stall == `True) begin
//        stall_state = `ExStall; 
    end else if (id_stall == `True) begin
        stall_state = `IdStall; 
    end else if (if_stall == `True) begin
        stall_state = `IfStall; 
//    end else if (mctl_stall == `True) begin
//        stall_state = `MctlStall;
    end else begin
        stall_state = `NoStall; 
    end
end
endmodule