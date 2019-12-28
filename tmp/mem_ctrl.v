module mem_ctrl (
    input wire clk,
    input wire rst,
    
    input wire                  ram_r_req_i,
    input wire                  ram_w_req_i,
    input wire[`MemBus]         ram_addr_i,
    input wire[`RegBus]         ram_data_i,
    input wire[1:0]             ram_state_i,

    input wire                  inst_fe,
    input wire[`InstAddrBus]    inst_fpc,
    
    output reg[`InstBus]        inst_o,
    output reg[`InstAddrBus]    inst_pc,
    output reg                  inst_ok,

    output reg                  ram_done_o,
    output reg[`RegBus]         ram_data_o,

    input wire[`RamBus]         cpu_din,
    output reg[`RamBus]         cpu_dout,
    output reg[`MemBus]         cpu_mem_a,
    output reg                  cpu_mem_wr

//    output reg                  mctl_stall
);


reg[4:0]        stage;
reg[1:0]        type;
reg[`MemBus]    ram_addr;
reg[`RegBus]     ram_data;
reg[`InstAddrBus] predicted_pc;

integer i; 

always @ (posedge clk) begin
    if (rst == `RstEnable) begin
        stage       <= 5'h0;
        ram_addr    <= `ZeroWord;
        ram_data    <= `ZeroWord;
        ram_data_o  <= `ZeroWord;
        cpu_mem_a   <= `ZeroWord;
        cpu_mem_wr  <= `Read;
        cpu_dout    <= 8'b00000000;
        type        <= `NONE;
        inst_o      <= `ZeroWord;
        inst_pc     <= `ZeroWord;
        inst_ok     <= `False;
        ram_done_o  <= `False;
        predicted_pc <= 32'hffffffff;
    end else begin
        if (stage[4] == `True && stage[3] == `Read) begin // Reading
            ram_done_o  <= `False;
            inst_ok     <= `False;
            if (type == `INSR && inst_fe && inst_fpc != ram_addr) begin // Wrong prediction, stop as we don't need it
                ram_addr    <= inst_fpc;
                stage[4:0]  <= 5'b10100;
                cpu_mem_a   <= inst_fpc + 3;
                cpu_mem_wr  <= `Read;
                type        <= `INSR;
            end else begin
                case (stage[2:0])
                    3'h4: begin
                        cpu_mem_a       <= ram_addr + 2;
                        cpu_mem_wr      <= `Read;
                        stage[2:0]      <= 3'h3;
                    end
                    3'h3: begin
                        ram_data[31:24] <= cpu_din;
                        cpu_mem_a       <= ram_addr + 1;
                        cpu_mem_wr      <= `Read;
                        stage[2:0]      <= 3'h2;
                    end
                    3'h2: begin
                        ram_data[23:16] <= cpu_din;
                        cpu_mem_a       <= ram_addr + 0;
                        cpu_mem_wr      <= `Read;
                        stage[2:0]      <= 3'h1;
                    end
                    3'h1: begin
                        ram_data[15:8]  <= cpu_din;
                        if (type == `INSR) begin  // prefetch next predicted pc
                            predicted_pc    <= inst_pc + 4;
                            cpu_mem_a       <= inst_pc + 7;
                            cpu_mem_wr      <= `Read;
                        end else begin
                            predicted_pc    <= inst_pc;
                            cpu_mem_a       <= inst_pc + 3;
                            cpu_mem_wr      <= `Read;
                        end
                        stage[2:0]      <= 3'h0;
                    end
                    3'h0: begin
                        stage[4:0]      <= 5'h0;
                        if (type == `INSR) begin
                            inst_pc     <= ram_addr;
                            inst_o      <= {ram_data[31:8],cpu_din};
                            inst_ok     <= `True;
                            // avoid useless stall
                            if (ram_r_req_i) begin
                                ram_addr    <= ram_addr_i;
                                case (ram_state_i)
                                    4'h3: begin
                                        stage[4:0]  <= 5'b10100;
                                    end
                                    4'h1: begin
                                        stage[4:0]  <= 5'b10010;
                                    end
                                    4'h0: begin
                                        stage[4:0]  <= 5'b10001;
                                    end
                                endcase
                                cpu_mem_a   <= ram_addr_i + ram_state_i;
                                cpu_mem_wr  <= `Read;
                                type        <= `RAMR;
                            end else if (ram_w_req_i) begin
                                ram_addr    <= ram_addr_i;
                                ram_data    <= ram_data_i;
                                cpu_mem_a   <= ram_addr_i + ram_state_i;
                                cpu_mem_wr  <= `Write;
                                type        <= `RAMW;
                                case (ram_state_i)
                                    4'h3: begin
                                        cpu_dout    <= ram_data_i[31:24];
                                        stage[4:0]  <= 5'b11011;
                                    end
                                    4'h1: begin
                                        cpu_dout    <= ram_data_i[15:8];
                                        stage[4:0]  <= 5'b11001;
                                    end
                                    4'h0: begin
                                        cpu_dout    <= ram_data_i[7:0];
                                        stage[4:0]  <= 5'h0;
                                        ram_done_o  <= `True;
                                    end
                                endcase
                            end else begin // prefetch next predicted pc
                                cpu_mem_wr      <= `Read;
                                type            <= `INSR;
                                ram_addr        <= inst_fpc + 4;
                                if (predicted_pc == inst_fpc + 4) begin
                                    cpu_mem_a       <= inst_fpc + 6;
                                    stage[4:0]      <= 5'b10011;
                                end else begin
                                    cpu_mem_a       <= inst_fpc + 7;
                                    stage[4:0]      <= 5'b10100;
                                end
                            end
                        end else begin
                            ram_done_o  <= `True;
                            ram_data_o  <= {ram_data[31:8],cpu_din};
                            if (inst_fe) begin // IF
                                ram_addr        <= inst_fpc;
                                cpu_mem_wr      <= `Read;
                                type            <= `INSR;
                                if (predicted_pc == inst_fpc) begin
                                    stage[4:0]      <= 5'b10011;
                                    cpu_mem_a       <= inst_fpc + 2;
                                end else begin
                                    stage[4:0]      <= 5'b10100;
                                    cpu_mem_a       <= inst_fpc + 3;
                                end
                            end
                        end
                    end
                endcase
            end
        end else if (stage[4] == `True && stage[3] == `Write) begin // Writing
            ram_done_o  <= `False;
            inst_ok     <= `False;
            case (stage[1:0])
                3'h3: begin
                    cpu_dout    <= ram_data[23:16];
                    cpu_mem_a   <= ram_addr + 2;
                    cpu_mem_wr  <= `Write;
                    stage[1:0]  <= 3'h2;
                end
                3'h2: begin
                    cpu_dout    <= ram_data[15:8];
                    cpu_mem_a   <= ram_addr + 1;
                    cpu_mem_wr  <= `Write;
                    stage[1:0]  <= 3'h1;
                end
                3'h1: begin
                    cpu_dout    <= ram_data[7:0];
                    cpu_mem_a   <= ram_addr + 0;
                    cpu_mem_wr  <= `Write;
                    stage[4:0]  <= 5'h0;
                    ram_done_o  <= `True;
                end
            endcase
        end else if (!ram_done_o && ram_r_req_i == `True) begin
            inst_ok     <= `False;
            ram_addr    <= ram_addr_i;
            case (ram_state_i)
                4'h3: begin
                    stage[4:0]  <= 5'b10100;
                end
                4'h1: begin
                    stage[4:0]  <= 5'b10010;
                end
                4'h0: begin
                    stage[4:0]  <= 5'b10001;
                end
            endcase
            cpu_mem_a   <= ram_addr_i + ram_state_i;
            cpu_mem_wr  <= `Read;
            type        <= `RAMR;
        end else if (!ram_done_o && ram_w_req_i == `True) begin
            inst_ok     <= `False;
            ram_addr    <= ram_addr_i;
            ram_data    <= ram_data_i;
            cpu_mem_a   <= ram_addr_i + ram_state_i;
            cpu_mem_wr  <= `Write;
            type        <= `RAMW;
            case (ram_state_i)
                4'h3: begin
                    cpu_dout    <= ram_data_i[31:24];
                    stage[4:0]  <= 5'b11011;
                end
                4'h1: begin
                    cpu_dout    <= ram_data_i[15:8];
                    stage[4:0]  <= 5'b11001;
                end
                4'h0: begin
                    cpu_dout    <= ram_data_i[7:0];
                    stage[4:0]  <= 5'h0;
                    ram_done_o  <= `True;
                end
            endcase
        end else if (inst_fe) begin // IF
    //        $display("start fetch %d", pc);
            ram_addr    <= inst_fpc;
            stage[4:0]  <= 5'b10100;
            cpu_mem_a   <= inst_fpc + 3;
            cpu_mem_wr  <= `Read;
            type        <= `INSR;
            ram_done_o  <= `False;
            inst_ok     <= `False;
        end else begin
            ram_done_o  <= `False;
            inst_ok     <= `False;
        end
    end
end


endmodule