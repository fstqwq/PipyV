`include "defines.vh"
module mem (
    input wire rst,

    input wire[`RegAddrBus] wd_i,
    input wire              wreg_i,
    input wire[`RegBus]     wdata_i,

    input wire[`AluOpBus]   aluop_i,
    //input wire[`MemBus]     mem_addr_i,

    input wire[`RegBus]     ram_r_data_i,

    input wire[`RegBus]     ram_addr_i,

    input wire              ram_done,
    input wire              ram_busy,

    output reg[`RegAddrBus] wd_o,
    output reg              wreg_o,
    output reg[`RegBus]     wdata_o,
    output reg              stall_req_o,
    output reg              ram_r_enable_o,

    output reg[`RegBus]     ram_addr_o,
    output reg              ram_w_enable_o,
    output reg[`RegBus]     ram_w_data_o,
    output reg[1:0]         ram_mask_o
);

always @ ( * ) begin
    if(rst == `RstEnable) begin
        wd_o = `NOPRegAddr;
        wreg_o = `WriteDisable;
        wdata_o = `ZeroWord;
        ram_r_enable_o = 1'b0;
        ram_w_enable_o = 1'b0;
        stall_req_o = `NoStop;
        ram_w_data_o = `ZeroWord;
        ram_addr_o = `ZeroWord;
        ram_mask_o = 4'h0;
    end else if(aluop_i == `ME_NOP_OP)begin
        //case(aluop_i)
            //`ME_NOP_OP: begin
                wd_o = wd_i;
                wreg_o = wreg_i;
                wdata_o = wdata_i;
                ram_r_enable_o = 1'b0;
                ram_w_enable_o = 1'b0;
                stall_req_o = `NoStop;
                ram_w_data_o = `ZeroWord;
                ram_addr_o = `ZeroWord;
                ram_mask_o = 4'h0;
        //    end

        //    default: begin
        //    end
        //endcase
    end else begin
        wd_o = wd_i;
        wreg_o = wreg_i;
        wdata_o = wdata_i;
        ram_r_enable_o = 1'b0;
        stall_req_o = `NoStop;
        ram_w_data_o = `ZeroWord;
        ram_w_enable_o = 1'b0;
        ram_addr_o = `ZeroWord;
        ram_mask_o = 4'h0;
        if(ram_done) begin
            stall_req_o = 1'b0;
            case(aluop_i)
                `EX_LB_OP: begin
                    if(ram_addr_i[17:16] == 2'b11) begin
                        wdata_o = {{24{ram_r_data_i[31]}},ram_r_data_i[31:24]};
                    end else  begin
                        case (ram_addr_i[1:0])
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
                            default: begin
                                wdata_o = `ZeroWord;
                            end
                        endcase
                    end
                end
                `EX_LH_OP: begin
                    case (ram_addr_i[1:0])
                        2'b10: begin
                            wdata_o = {{12{ram_r_data_i[31]}},ram_r_data_i[31:16]};
                        end
                        2'b00: begin
                            wdata_o = {{12{ram_r_data_i[15]}},ram_r_data_i[15:0]};
                        end
                        default: begin
                            wdata_o = `ZeroWord;
                        end
                    endcase
                end
                `EX_LW_OP: begin
                    wdata_o = ram_r_data_i;
                end
                `EX_LBU_OP: begin
                    if(ram_addr_i[17:16] == 2'b11) begin
                        wdata_o = {{24{1'b0}},ram_r_data_i[31:24]};
                    end else begin
                        case (ram_addr_i[1:0])
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
                            default: begin
                                wdata_o = `ZeroWord;
                            end
                        endcase
                    end
                end
                `EX_LHU_OP: begin
                    case (ram_addr_i[1:0])
                        2'b10: begin
                            wdata_o = {{12{1'b0}},ram_r_data_i[31:16]};
                        end
                        2'b00: begin
                            wdata_o = {{12{1'b0}},ram_r_data_i[15:0]};
                        end
                        default: begin
                            wdata_o = `ZeroWord;
                        end
                    endcase
                end
                default: begin
                    wdata_o = wdata_i;
                end
            endcase
        end else if(!ram_busy) begin
            stall_req_o = `Stop;
            wdata_o = wdata_i;
            case(aluop_i)
                `EX_LW_OP,`EX_LH_OP,`EX_LB_OP,`EX_LHU_OP,`EX_LBU_OP: begin
                    ram_r_enable_o = `WriteEnable;
                    if(ram_addr_i[17:16] == 2'b11) begin
                        ram_addr_o = ram_addr_i;
                    end else begin
                        ram_addr_o = {ram_addr_i[31:2],2'b00};
                    end
                end
                `EX_SB_OP: begin
                    ram_w_enable_o = `WriteEnable;
                    ram_addr_o = ram_addr_i;
                    ram_w_data_o = {4{wdata_i[7:0]}};
                    ram_mask_o = 2'b01;
                end
                `EX_SH_OP: begin
                    ram_w_enable_o = `WriteEnable;
                    ram_addr_o = ram_addr_i;
                    ram_w_data_o = {2{wdata_i[15:0]}};
                    ram_mask_o = 2'b10;
                end
                `EX_SW_OP: begin
                    ram_w_enable_o = `WriteEnable;
                    ram_addr_o = ram_addr_i;
                    ram_w_data_o = wdata_i;
                    ram_mask_o = 2'b11;
                end
            endcase
        end else begin
            stall_req_o = `Stop;
        end
    end
end

endmodule // mem
