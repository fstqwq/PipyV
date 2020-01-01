`include "defines.v"

module mem (
    input wire rst,

    input wire[`RegAddrBus] wd_i,
    input wire              wreg_i,
    input wire[`RegBus]     wdata_i,

    
    output reg[`RegAddrBus] wd_o,
    output reg              wreg_o,
    output reg[`RegBus]     wdata_o,

    input wire[`AluOpBus]   aluop_i,
    input wire[`MemBus]     addr_i,

    input wire              ram_done_i,
    input wire[`RegBus]     ram_r_data_i,

    output reg              ram_r_req_o,
    output reg              ram_w_req_o,
    output reg[`RegBus]     ram_addr_o,
    output reg[`RegBus]     ram_w_data_o,
    output reg[1:0]         ram_state,

    output reg              mem_stall
);

always @ (*) begin
    if (rst == `RstEnable) begin
        wd_o            = `NOPRegAddr;
        wreg_o          = `False;
        wdata_o         = `ZeroWord;
        ram_r_req_o     = `False;
        ram_w_req_o     = `False;
        ram_w_data_o    = `ZeroWord;
        ram_addr_o      = `ZeroWord;
        ram_state       = 2'h0;
        mem_stall       = `False;
    end else begin
        wd_o            = wd_i;
        wreg_o          = wreg_i;
        case(aluop_i)
            `MEM_NOP: begin
                ram_r_req_o     = `False;
                ram_w_req_o     = `False;
                ram_w_data_o    = `ZeroWord;
                ram_addr_o      = `ZeroWord;
                ram_state       = 2'h0;
                mem_stall       = `False;
                wdata_o         = wdata_i;
            end
            `EX_LB: begin
                ram_r_req_o     = `True;
                ram_w_req_o     = `False;
                ram_w_data_o    = `ZeroWord;
                ram_addr_o      = addr_i;
                wdata_o        = {{24{ram_r_data_i[7]}},ram_r_data_i[7:0]};
                ram_state       = 2'b00;
                mem_stall       = !ram_done_i;
            end
            `EX_LBU: begin
                ram_r_req_o     = `True;
                ram_w_req_o     = `False;
                ram_w_data_o    = `ZeroWord;
                ram_addr_o      = addr_i;
                wdata_o         = {24'b0,ram_r_data_i[7:0]};
                ram_state       = 2'b00;
                mem_stall       = !ram_done_i;
            end
            `EX_LH: begin
                ram_r_req_o     = `True;
                ram_w_req_o     = `False;
                ram_w_data_o    = `ZeroWord;
                ram_addr_o      = addr_i;
                wdata_o        = {{16{ram_r_data_i[15]}},ram_r_data_i[15:0]};
                ram_state       = 2'b01;
                mem_stall       = !ram_done_i;
            end
            `EX_LHU: begin
                ram_r_req_o     = `True;
                ram_w_req_o     = `False;
                ram_w_data_o    = `ZeroWord;
                ram_addr_o      = addr_i;
                wdata_o        = {16'b0,ram_r_data_i[15:0]};
                ram_state       = 2'b01;
                mem_stall       = !ram_done_i;
            end
            `EX_LW: begin
                ram_r_req_o     = `True;
                ram_w_req_o     = `False;
                ram_w_data_o    = `ZeroWord;
                ram_addr_o      = addr_i;
                wdata_o         = ram_r_data_i;
                ram_state       = 2'b11;
                mem_stall       = !ram_done_i;
            end
            `EX_SB: begin
                ram_r_req_o     = `False;
                ram_w_req_o     = `True;
                ram_addr_o      = addr_i;
                ram_w_data_o    = wdata_i;
                wdata_o         = wdata_i;
                ram_state       = 2'b00;
                mem_stall       = !ram_done_i;
            end
            `EX_SH: begin
                ram_r_req_o     = `False;
                ram_w_req_o     = `True;
                ram_addr_o      = addr_i;
                ram_w_data_o    = wdata_i;
                wdata_o         = wdata_i;
                ram_state       = 2'b01;
                mem_stall       = !ram_done_i;
            end
            `EX_SW: begin
                ram_r_req_o     = `False;
                ram_w_req_o     = `True;
                ram_addr_o      = addr_i;
                ram_w_data_o    = wdata_i;
                wdata_o         = wdata_i;
                ram_state       = 2'b11;
                mem_stall       = !ram_done_i;
            end
            default: begin
                ram_r_req_o     = `False;
                ram_w_req_o     = `False;
                ram_w_data_o    = `ZeroWord;
                ram_addr_o      = `ZeroWord;
                wdata_o         = `ZeroWord;
                ram_state       = 2'b0;
                mem_stall       = `False;
            end
        endcase
    end
    
end


endmodule