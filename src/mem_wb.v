`include "defines.v"

module mem_wb (
    input wire clk,
    input wire rst,

    input wire[`RegAddrBus] mem_wd,
    input wire              mem_wreg,
    input wire[`RegBus]     mem_wdata,

    input wire[`StallBus]    stall_state,

    output reg[`RegAddrBus] wb_wd,
    output reg              wb_wreg,
    output reg[`RegBus]     wb_wdata
);
always @ (posedge clk) begin
    if (rst == `RstEnable) begin
        wb_wd       <= `NOPRegAddr;
        wb_wreg     <= `False;
        wb_wdata    <= `ZeroWord;
    end else if (stall_state[4] == `True) begin
        wb_wd       <= `NOPRegAddr;
        wb_wreg     <= `False;
        wb_wdata    <= `ZeroWord;
    end else begin
/*        if (mem_wreg) begin
            $display("WB : [%h]%3h", mem_wd, mem_wdata);
        end*/
        wb_wd       <= mem_wd;
        wb_wreg     <= mem_wreg;
        wb_wdata    <= mem_wdata;
    end
end

endmodule