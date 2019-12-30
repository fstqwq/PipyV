`include "defines.v"

module mem (
    input wire clk,
    input wire rst,

    input wire[`RegAddrBus] wd_i,
    input wire              wreg_i,
    input wire[`RegBus]     wdata_i,

    input wire[`AluOpBus]   aluop_i,
    input wire[`MemBus]     addr_i,

    output reg[`RegAddrBus] wd_o,
    output reg              wreg_o,
    output reg[`RegBus]     wdata_o,

//  interacting with ex_mem
    input wire              inquiry_i,

//  interacting with mem_ctrl
    input wire              ram_busy_i,
    input wire[`RegBus]     ram_r_data_i,
    input wire              ram_sync_i,

    output reg              ram_sync_o,
    output reg              ram_r_req_o,
    output reg              ram_w_req_o,
    output reg[`RegBus]     ram_addr_o,
    output reg[`RegBus]     ram_w_data_o,
    output reg[1:0]         ram_state,

    output reg              mem_stall
);


reg processed;
/*

    input wire[`RegAddrBus] wd_i,
    input wire              wreg_i,
    input wire[`RegBus]     wdata_i,
*/

always @ (*) begin
    /*
        When loading data, we need to wait until data is ready;
        When storing data, we don't need to wait, if no memory operation is needed. 
    */
//    $display("aha stall=%d inq=%d pro=%d sync1=%d sync2=%d", mem_stall,     inquiry_i, processed, ram_sync_i, ram_sync_o);
    if (rst == `RstEnable) begin
//        $display("CLEAR MEM");
        wd_o            = `NOPRegAddr;
        wreg_o          = `False;
        wdata_o         = `ZeroWord;
        mem_stall       = `False;
        ram_sync_o      = 1'b0;
        processed       = 1'b0;
        ram_r_req_o     = `False;
        ram_w_req_o     = `False;
        ram_w_data_o    = `ZeroWord;
        ram_addr_o      = `ZeroWord;
        ram_state       = 2'h0;
    end else if (aluop_i == `MEM_NOP && aluop_i == `MEM_NOP) begin // only operate register
//        $display("NOP %h %h %h", wd_i, wreg_i, wdata_i);
        wd_o            = wd_i;
        wreg_o          = wreg_i;
        wdata_o         = wdata_i;
        mem_stall       = `False;
        ram_r_req_o     = `False;
        ram_w_req_o     = `False;
        ram_w_data_o    = `ZeroWord;
        ram_addr_o      = `ZeroWord;
        ram_state       = 2'h0;
    end else begin // load or store
//        $display("Mem : %d %d %d %d", ram_busy_i, ram_sync_i, ram_sync_o, aluop_i);
//            $display("not busy");
        if (ram_busy_i == `True || ram_sync_i != ram_sync_o) begin
//            $display("mem busy");
            mem_stall    = `True;
        end else if (ram_sync_i == ram_sync_o && processed != ram_sync_o) begin // process returned data
//            $display("mem process");
            wd_o            = wd_i;
            wreg_o          = wreg_i;
            processed       = !processed;
            case(aluop_i)
                `EX_LB: begin
                    if(addr_i[17:16] == 2'b11) begin
                        wdata_o = {{24{ram_r_data_i[31]}},ram_r_data_i[31:24]};
                    end else begin
                        case (addr_i[1:0])
                            2'b11: begin
                                wdata_o = {{24{ram_r_data_i[31]}},ram_r_data_i[31:24]};
                            end
                            2'b10: begin
                                wdata_o = {{24{ram_r_data_i[23]}},ram_r_data_i[23:16]};
                            end
                            2'b01: begin
                                wdata_o = {{24{ram_r_data_i[15]}},ram_r_data_i[15:8]};
                            end
                            2'b00: begin
                                wdata_o = {{24{ram_r_data_i[7]}},ram_r_data_i[7:0]};
                            end
                        endcase
                    end
                end
                `EX_LH: begin
                    case (addr_i[1:0])
                        2'b10: begin
                            wdata_o = {{12{ram_r_data_i[31]}},ram_r_data_i[31:16]};
                        end
                        2'b00: begin
                            wdata_o = {{12{ram_r_data_i[15]}},ram_r_data_i[15:0]};
                        end
                        default: begin // Error!
                            wdata_o = `ZeroWord;
                        end
                    endcase
                end
                `EX_LW: begin
                    wdata_o = ram_r_data_i;
                end
                `EX_LBU: begin
                    if(addr_i[17:16] == 2'b11) begin
                        wdata_o = {{24{1'b0}},ram_r_data_i[31:24]};
                    end else begin
                        case (addr_i[1:0])
                            2'b11: begin
                                wdata_o = {{24{1'b0}},ram_r_data_i[31:24]};
                            end
                            2'b10: begin
                                wdata_o = {{24{1'b0}},ram_r_data_i[23:16]};
                            end
                            2'b01: begin
                                wdata_o = {{24{1'b0}},ram_r_data_i[15:8]};
                            end
                            2'b00: begin
                                wdata_o = {{24{1'b0}},ram_r_data_i[7:0]};
                            end
                        endcase
                    end
//                    $display("LBU : %h %h %h", ram_addr_o, ram_r_data_i, wdata_o);
                end
                `EX_LHU: begin
                    case (addr_i[1:0])
                        2'b10: begin
                            wdata_o = {{12{1'b0}},ram_r_data_i[31:16]};
                        end
                        2'b00: begin
                            wdata_o = {{12{1'b0}},ram_r_data_i[15:0]};
                        end
                        default: begin // Error!
                            wdata_o = `ZeroWord;
                        end
                    endcase
                end
                default: begin
                    wdata_o = wdata_i;
                end
            endcase
            mem_stall       = `False;
            ram_r_req_o     = `False;
            ram_w_req_o     = `False;
            ram_w_data_o    = `ZeroWord;
            ram_addr_o      = `ZeroWord;
        end else if (ram_sync_i == ram_sync_o && processed == ram_sync_o) begin
//            $display("synced, %1d %1d", processed, inquiry_i);
            if (processed != inquiry_i) begin
                mem_stall       = `False;
                case(aluop_i)
                    `EX_LW, `EX_LH, `EX_LB, `EX_LHU, `EX_LBU: begin
                        if(addr_i[17:16] == 2'b11) begin
                            ram_addr_o  = addr_i;
                            ram_state   = 2'b00;
                        end else begin
                            ram_addr_o  = {addr_i[31:2], 2'b00};
                            ram_state   = 2'b11;
                        end
                        ram_r_req_o     = `True;
                        ram_w_req_o     = `False;
                        mem_stall       = `True;
                        ram_sync_o      = !ram_sync_o;
//                        $display("start LBU : %h", addr_i);
                    end
                    `EX_SB: begin
                        ram_r_req_o     = `False;
                        ram_w_req_o     = `True;
                        ram_addr_o      = addr_i;
                        ram_w_data_o    = wdata_i;
                        ram_state       = 2'b00;
                        mem_stall       = `True;
                        processed       = !processed;
                        ram_sync_o      = !ram_sync_o;
//                        $display("start SB : %h", ram_addr_o);
                    end
                    `EX_SH: begin
                        ram_r_req_o     = `False;
                        ram_w_req_o     = `True;
                        ram_addr_o      = addr_i;
                        ram_w_data_o    = wdata_i;
                        ram_state       = 2'b01;
                        mem_stall       = `True;
                        processed       = !processed;
                        ram_sync_o      = !ram_sync_o;
                    end
                    `EX_SW: begin
                        ram_r_req_o     = `False;
                        ram_w_req_o     = `True;
                        ram_addr_o      = addr_i;
                        ram_w_data_o    = wdata_i;
                        ram_state       = 2'b11;
                        mem_stall       = `True;
                        processed       = !processed;
                        ram_sync_o      = !ram_sync_o;
                    end
                    default: begin
                        mem_stall       = `False;
                        ram_r_req_o     = `False;
                        ram_w_req_o     = `False;
                        ram_w_data_o    = `ZeroWord;
                        ram_addr_o      = `ZeroWord;
                    end
                endcase
            end else begin
                mem_stall       = `False;
                ram_r_req_o     = `False;
                ram_w_req_o     = `False;
                ram_w_data_o    = `ZeroWord;
                ram_addr_o      = `ZeroWord;
            end
        end
    end
    
end


endmodule