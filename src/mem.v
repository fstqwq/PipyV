`include "defines.v"

module mem (
    input wire rst,

    input wire[`RegAddrBus] wd_i,
    input wire              wreg_i,
    input wire[`RegBus]     wdata_i,

    input wire[`AluOpBus]   aluop_i,
    input wire[`MemBus]     addr_i,

    output reg[`RegAddrBus] wd_o,
    output reg              wreg_o,
    output reg[`RegBus]     wdata_o,

//  interacting with mem_ctrl
    input wire              ram_busy_i,
    input wire[`RegBus]     ram_r_data_i,
    input wire              ram_ok,

    output reg              mem_ack_o,
    output reg              ram_r_req_o,
    output reg              ram_w_req_o,
    output reg[`RegBus]     ram_addr_o,
    output reg[`RegBus]     ram_w_data_o,
    output reg[1:0]         ram_state,

    output reg              mem_stall
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read takes 2 cycles(wait till next cycle), write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)

integer debug;

always @ (*) begin
//$display("mem : %d", debug);
debug = debug + 1;
    /*
        When loading data, we need to wait until data is ready;
        When storing data, we don't need to wait, if no memory operation is needed. 
    */
    if (rst == `RstEnable) begin
        debug = 0;
        wd_o            = `NOPRegAddr;
        wreg_o          = `False;
        wdata_o         = `ZeroWord;
        mem_stall       = `False;
        mem_ack_o       = `True;
        ram_r_req_o     = `False;
        ram_w_req_o     = `False;
        ram_w_data_o    = `ZeroWord;
        ram_addr_o      = `ZeroWord;
        ram_state       = 2'h0;
    end else if (aluop_i == `MEM_NOP) begin // only operate register
        wd_o            = `NOPRegAddr;
        wreg_o          = `False;
        wdata_o         = `ZeroWord;
        mem_stall       = `False;
        mem_ack_o       = `True;
        ram_r_req_o     = `False;
        ram_w_req_o     = `False;
        ram_w_data_o    = `ZeroWord;
        ram_addr_o      = `ZeroWord;
        ram_state       = 2'h0;
    end else begin // load or store
//        $display("Mem : %d %d %d", ram_busy_i, mem_ack_o, aluop_i);
        if (ram_busy_i == `False) begin
            if (ram_ok == `True) begin // process returned data
                wd_o            = wd_i;
                wreg_o          = wreg_i;
                wdata_o         = wdata_i; 
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
                mem_ack_o       = `True;
                ram_r_req_o     = `False;
                ram_w_req_o     = `False;
                ram_w_data_o    = `ZeroWord;
                ram_addr_o      = `ZeroWord;
            end else begin
                case(aluop_i)
                    `EX_LW, `EX_LH, `EX_LB, `EX_LHU, `EX_LBU: begin
                        ram_r_req_o     = `True;
                        ram_w_req_o     = `False;
                        if(addr_i[17:16] == 2'b11) begin
                            ram_addr_o  = addr_i;
                            ram_state   = 2'b01;
                        end else begin
                            ram_addr_o  = {addr_i[31:2], 2'b00};
                            ram_state   = 2'b11;
                        end
                        mem_stall       = `True;
                        mem_ack_o       = `False;
                    end
                    `EX_SB: begin
                        ram_r_req_o     = `False;
                        ram_w_req_o     = `True;
                        ram_addr_o      = addr_i;
                        ram_w_data_o    = {24'h0, {wdata_i[7:0]}};
                        ram_state       = 2'b01;
                        mem_stall       = `True;
                        mem_ack_o       = `False;
                    end
                    `EX_SH: begin
                        ram_r_req_o     = `False;
                        ram_w_req_o     = `True;
                        ram_addr_o      = addr_i;
                        ram_w_data_o    = {16'h0, {wdata_i[15:0]}};
                        mem_stall       = `True;
                        mem_ack_o       = `False;
                    end
                    `EX_SW: begin
                        ram_r_req_o     = `False;
                        ram_w_req_o     = `True;
                        ram_addr_o      = addr_i;
                        ram_w_data_o    = wdata_i;
                        ram_state       = 2'b11;
                        mem_stall       = `True;
                        mem_ack_o       = `False;
                    end
                    default: begin
                        mem_stall       = `False;
                        mem_ack_o       = `True;
                        ram_r_req_o     = `False;
                        ram_w_req_o     = `False;
                        ram_w_data_o    = `ZeroWord;
                        ram_addr_o      = `ZeroWord;
                    end
                endcase
            end
        end else begin
            mem_ack_o       = `False;
            mem_stall       = `True;
        end
    end
end


endmodule