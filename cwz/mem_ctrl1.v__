module mem_ctrl (
    input wire clk,
    input wire rst,
    input wire[`MemBus] ram_addr_i,
    input wire[`RegBus] ram_data_i,
    input wire ram_r_enable_i,
    input wire ram_w_enable_i,
    input wire[1:0] ram_mask_i,
    input wire[`InstAddrBus] pc,
    //input wire[7:0] cpu_data_i,
    input wire[7:0] din,
//    input wire[`StallBus] stall,
    input wire rdy_in,

    output reg cpu_wr,
    output reg ram_busy,
    output reg ram_done,
    output reg pc_done,
    output reg[`RegBus] ram_addr_o,
    output reg[`RegBus] ram_r_data_o,
    output reg[`InstBus] pc_num,
    output reg[7:0] cpu_data_o,
//    output reg pc_enable;
    output reg[`InstBus] inst_o
);

reg[2:0] read_sta;
//reg read_enable;
reg mpc;
reg cur_done;
reg[`InstAddrBus] addr_i;
reg[`RegBus] data_o;
reg[`RegBus] form_data;
reg[1:0] cur_mask;
reg inreg;
reg fmask;

reg[`CacheBus] pcche[`CacheSize - 1:0];
reg[`InstBus] instche[`CacheSize - 1:0];
//reg vldche[`CacheSize - 1:0];

reg[`CacheBus] pcche1[`CacheSize - 1:0];
reg[`InstBus] instche1[`CacheSize - 1:0];
//reg vldche1[`CacheSize - 1:0];

reg [`CacheSize - 1:0] lruchoose;

wire[4:0] pcc;

assign pcc = pc[`CacheChoose];
/*
always @ ( * ) begin
    if(rst == `RstEnable) begin
        read_enable = 1'b0;
        mpc = 1'b0;
        //cpu_wr = 1'b0;
    end else if((read_sta == 4'h0 || read_sta == 4'h5))begin
        if(ram_r_enable_i == `WriteEnable) begin
            mpc = 1'b1;
            read_enable = 1'b1;
            //cpu_wr = 1'b1;
            addr_i = ram_addr_i;
        end else begin
            addr_i = pc;
            //pc_num = pc;
            mpc = 1'b0;
            read_enable = 1'b1;
            //cpu_wr = 1'b0;
        end
    end
end*/

/*
always @ ( * ) begin
    if(rst == `RstEnable) begin
        cur_mask = 2'b00;
        //mpc = 1'b0;
    //    read_enable = 1'b0;
    end else if(cur_mask == 2'b00) begin
            cur_mask = ram_mask_i;
    //end else begin
        //cur_mask =
    end else begin
        cur_mask = fmask;
        //mpc = fmpc;
    end
end
*/
reg cashhit;
integer i;

always @ ( posedge clk ) begin

    //fmask <= cur_mask;
    //cur_done <= 1'b0;
    //ram_done <= 1'b0;
    if(rst == `RstEnable) begin
        read_sta <= 3'h0;
        ram_busy <= 1'b1;
        cpu_wr <= 1'b0;
        cur_done <= 1'b0;
    //    ram_done <= 1'b0;
        mpc <= 1'b0;
        form_data <= `ZeroWord;
        ram_addr_o <= `ZeroWord;
        cashhit <= 1'b0;
    //    cur_mask <= 2'b00;
    end else if (!rdy_in) begin
        ram_busy <= 1'b1;
        cpu_wr <= 1'b0;
        cur_done <= 1'b0;
        cashhit <= 1'b0;
        ram_addr_o <= `ZeroWord;
    //    ram_done <= 1'b0;
        form_data <= data_o;
    //end

    end else if ((cpu_wr == 1'b1 && read_sta != 4'h0 && read_sta != 4'h5)) begin
        cpu_wr <= 1'b1;
        cashhit <= 1'b0;
        form_data <= data_o;
    //    if(cur_mask == 2'b00)
    //        cur_mask <= ram_mask_i;
        //$display("write start");
        case(cur_mask)
            2'b10: begin
                case (read_sta)
                /*    4'h0,4'h5: begin
                        ram_busy <= 1'b1;
                        cur_done <= 1'b0;
                //        ram_done <= 1'b0;
                //        data_o <= ram_data_i;
                        addr_i <= ram_addr_i;
                        ram_addr_o <= ram_addr_i;
                        cpu_data_o <= ram_data_i[7:0];
                        read_sta <= 4'h1;
                    end*/
                    4'h1: begin
                        ram_busy <= 1'b0;
                        cur_done <= 1'b1;
                        mpc <= 1'b1;
                //        ram_done <= 1'b1;
                        ram_addr_o <= addr_i + 1;
                        cpu_data_o <= data_o[15:8];
                        read_sta <= 4'h0;
                        cur_mask <= 2'b00;
                    end
                    /*4'h2: begin
                        ram_busy <= 1'b0;
                        ram_done <= 1'b1;
                        read_sta <= 4'h0;
                    end*/
                endcase
            end
            2'b11: begin
                case (read_sta)
                /*    4'h0,4'h5: begin
                        ram_busy <= 1'b1;
                //        ram_done <= 1'b0;
                        cur_done <= 1'b0;
                //        data_o <= ram_data_i;
                        addr_i <= ram_addr_i;
                        ram_addr_o <= ram_addr_i;
                        cpu_data_o <= ram_data_i[7:0];
                        read_sta <= 4'h1;
                    end*/
                    4'h1: begin
                        cur_done <= 1'b0;
                //        ram_done <= 1'b0;
                        ram_busy <= 1'b1;
                        ram_addr_o <= addr_i + 1;
                        cpu_data_o <= data_o[15:8];
                        read_sta <= read_sta + 1;
                    end
                    4'h2: begin
                        cur_done <= 1'b0;
                //        ram_done <= 1'b0;
                        ram_busy <= 1'b1;
                        ram_addr_o <= addr_i + 2;
                        cpu_data_o <= data_o[23:16];
                        read_sta <= read_sta + 1;
                    end
                    4'h3: begin
                        cur_done <= 1'b1;
                        mpc <= 1'b1;
                //        ram_done <= 1'b1;
                        ram_busy <= 1'b0;
                        ram_addr_o <= addr_i + 3;
                        cpu_data_o <= data_o[31:24];
                        read_sta <= 4'h0;//read_sta + 1;
                        cur_mask <= 2'b00;
                    end
                    /*4'h4: begin
                        ram_busy <= 1'b0;
                        ram_done <= 1'b1;
                        read_sta <= 4'h0;
                    end*/
                endcase
            end
            default: begin
            end
        endcase
    //end else if(ram_r_enable_i == `WriteEnable) begin
    end else if(ram_w_enable_i == `WriteEnable) begin
        cashhit <= 1'b0;
        cpu_wr <= 1'b1;
        form_data <= ram_data_i;
        case (ram_mask_i)
            2'b01: begin
            //    inreg <= 1'b1;
                cur_done <= 1'b1;
                mpc <= 1'b1;
            //    ram_done <= 1'b0;
                //cur_done <= 1'b0;
                ram_busy <= 1'b0;
                ram_addr_o <= ram_addr_i;
                //$display(ram_addr_o);
                cpu_data_o <= ram_data_i[7:0];
                cur_mask <= 2'b00;
            end
            2'b10: begin
                ram_busy <= 1'b1;
                cur_done <= 1'b0;
            //    ram_done <= 1'b0;
            //    data_o <= ram_data_i;
                addr_i <= ram_addr_i;
                ram_addr_o <= ram_addr_i;
                cpu_data_o <= ram_data_i[7:0];
                read_sta <= 4'h1;
                cur_mask <= ram_mask_i;
            end
            2'b11: begin
                ram_busy <= 1'b1;
            //    ram_done <= 1'b0;
                cur_done <= 1'b0;
            //    data_o <= ram_data_i;
                addr_i <= ram_addr_i;
                ram_addr_o <= ram_addr_i;
                cpu_data_o <= ram_data_i[7:0];
                read_sta <= 4'h1;
                cur_mask <= ram_mask_i;
            end
            default: begin
            end
        endcase
    end else begin
        cpu_wr <= 1'b0;
        //form_data <= data_o;
        case(read_sta)
            4'h0,4'h5: begin
            //    cur_done <= 1'b0;
            //    ram_done <= 1'b0;
            //    ram_busy <= 1'b1;
                if(ram_r_enable_i == `WriteEnable) begin
                    mpc <= 1'b1;
                    cur_done <= 1'b0;
                    ram_busy <= 1'b1;
                    addr_i <= ram_addr_i;
                    ram_addr_o <= ram_addr_i;
                    pc_num <= `ZeroWord;
                    form_data <= data_o;
                    read_sta <= 4'h1;
                    cashhit <= 1'b0;
                end else  begin
                    mpc <= 1'b0;
                    addr_i <= pc;
                    pc_num <= pc;
                    ram_addr_o <= pc;
                    case (pc[`RestChoose])
                        pcche[pcc]: begin
                            cur_done <= 1'b1;
                            ram_busy <= 1'b0;
                            form_data <= instche[pc[`CacheChoose]];
                            cashhit <= 1'b1;
                        end
                        pcche1[pcc]: begin
                            cur_done <= 1'b1;
                            ram_busy <= 1'b0;
                            form_data <= instche1[pc[`CacheChoose]];
                            cashhit <= 1'b1;
                        end
                        default: begin
                            cur_done <= 1'b0;
                            ram_busy <= 1'b1;
                            read_sta <= 4'b1;
                            form_data <= data_o;
                            cashhit <= 1'b0;
                        end
                    endcase
                end
                /*if(pc == pcche[pc[`CacheChoose]] && vldche[pc[`CacheChoose]] == 1'b1) begin
                    cashhit <= 1'b1;
                    mpc <= 1'b0;
                    cur_done <= 1'b1;
                    ram_busy <= 1'b0;
                    addr_i <= pc;
                    pc_num <= pc;
                    ram_addr_o <= pc;
                    form_data <= instche[pc[`CacheChoose]];
                //    lruchoose[pc[`CacheChoose]] = 1'b0;
                end else if(pc == pcche1[pc[`CacheChoose]] && vldche1[pc[`CacheChoose]] == 1'b1) begin
                    cashhit <= 1'b1;
                    mpc <= 1'b0;
                    cur_done <= 1'b1;
                    ram_busy <= 1'b0;
                    addr_i <= pc;
                    pc_num <= pc;
                    ram_addr_o <= pc;
                    form_data <= instche1[pc[`CacheChoose]];
                //    lruchoose[pc[`CacheChoose]] = 1'b1;
                end else begin
                    mpc <= 1'b0;
                    cur_done <= 1'b0;
                    ram_busy <= 1'b1;
                    addr_i <= pc;
                    pc_num <= pc;
                    ram_addr_o <= pc;
                    form_data <= data_o;
                    read_sta <= 4'h1;
                    cashhit <= 1'b0;
            //        end
                end
                */

            end
            4'h1: begin
                //ram_busy <= 1'b1;
                //data_o[7:0] <= din;
                //cur_done <= 1'b0;
                //ram_done <= 1'b0;
                form_data <= data_o;
                if(addr_i == 32'h30000) begin
                    cur_done <= 1'b1;
                    ram_addr_o <= addr_i;
                    read_sta <= 4'h5;
                end else begin
                    //ram_done <= 1'
                    ram_addr_o <= addr_i + 1;
                    read_sta <= read_sta + 1;
                end
            end
            4'h2: begin
                //ram_busy = 1'b1;
                //data_o[15:8] <= din;
                form_data <= data_o;
                ram_addr_o <= addr_i + 2;
                read_sta <= read_sta + 1;
            end
            4'h3: begin
                //ram_busy = 1'b1;
                //data_o[23:16] <= din;
                cur_done <= 1'b0;
            //    ram_done <= 1'b0;
                ram_addr_o <= addr_i + 3;
                read_sta <= read_sta + 1;
                form_data <= data_o;
            end
            4'h4: begin
                ram_busy <= 1'b0;
                cur_done <= 1'b1;
                //data_o[31:24] <= din;
                //cur_done <= 1'b0;
                //ram_done <= 1'b0;
                read_sta <= read_sta + 1;
                ram_addr_o <= addr_i + 3;
                form_data <= data_o;
                /*if(!mpc) begin
                    ram_done <= 1'b0;
                    pc_done <= 1'b1;
                    inst_o[31:24] <= din;
                    inst_o[23:0] <= data_o[23:0];
                end else begin
                    ram_done <= 1'b1;
                    pc_done <= 1'b0;
                    ram_r_data_o[23:0] <= data_o[23:0];
                    ram_r_data_o[31:24] <= din;
                end*/
            end
            default: begin
                form_data <= data_o;
            end
        endcase
    end
end

always @ ( * ) begin
    if(rst == `RstEnable) begin
        data_o = `ZeroWord;
    end else if(cashhit == 1'b1) begin
        data_o = form_data;
    end else if(!cpu_wr) begin
        case(read_sta)
            4'h2: begin
                data_o[7:0] = din;
                data_o[31:8] = form_data[31:8];
    /*            data_o[15:8] = data_o[15:8];
                data_o[23:16] = data_o[23:16];
                data_o[31:24] = data_o[31:24];*/
            end
            4'h3: begin
                //data_o[7:0] = data_o[7:0];
                data_o[15:8] = din;
                data_o[7:0] = form_data[7:0];
                data_o[31:16] = form_data[31:16];
                //data_o[23:16] = data_o[23:16];
                //data_o[31:24] = data_o[31:24];
            end
            4'h4: begin
            //    data_o[7:0] = data_o[7:0];
            //    data_o[15:8] = data_o[15:8];
                data_o[23:16] = din;
                data_o[15:0] = form_data[15:0];
                data_o[31:24] = form_data[31:24];
            //    data_o[31:24] = data_o[31:24];
            end
            4'h5: begin
            //    data_o[7:0] = data_o[7:0];
            //    data_o[15:8] = data_o[15:8];
            //    data_o[23:16] = data_o[23:16];
                data_o[23:0] = form_data[23:0];
                data_o[31:24] = din;
            end
            default: begin
                data_o = form_data;
            //    data_o[7:0] = data_o[7:0];
            //    data_o[15:8] = data_o[15:8];
            //    data_o[23:16] = data_o[23:16];
            //    data_o[31:24] = data_o[31:24];
            end
        endcase
    end else begin
        //if(read_sta != 4'h1) begin
            data_o = form_data;
        //end else begin
        //    data_o = ram_data_i;
        //end
    end
end

always @ ( * ) begin
    if( cur_done) begin
        if(!mpc) begin
            ram_done = 1'b0;
            pc_done = 1'b1;
            inst_o = data_o;
            ram_r_data_o = `ZeroWord;
        //    if(cashhit == 1'b1)
        //        $write("%h\n\n", inst_o);
        end else begin
            ram_done = 1'b1;
            pc_done = 1'b0;
            inst_o = `ZeroWord;
            ram_r_data_o = data_o;
        end
    end else begin
        inst_o = `ZeroWord;
        pc_done = 1'b0;
        ram_done = 1'b0;
        ram_r_data_o = `ZeroWord;
    end
end

always @ ( negedge clk ) begin
    if(rst == `RstEnable) begin
        for(i = 0; i < `CacheSize; i = i + 1) begin
//            vldche[i] <= 1'b0;
            pcche[i] <= `CacheClear;
            instche[i] <= `ZeroWord;
//            vldche1[i] <= 1'b0;
            pcche1[i] <= `CacheClear;
            instche1[i] <= `ZeroWord;
        end
    end else if(pc_done == 1'b1) begin
        if(pcche1[pc_num[`CacheChoose]] == pc_num[`RestChoose]) begin
            lruchoose[pc_num[`CacheChoose]] <= 1'b1;
        //    instche1[pc_num[`CacheChoose]] <= inst_o;
        end else if(pcche[pc_num[`CacheChoose]] == pc_num[`RestChoose]) begin
            lruchoose[pc_num[`CacheChoose]] <= 1'b0;
        //    instche[pc_num[`CacheChoose]] <= inst_o;
        end else if(lruchoose[pc_num[`CacheChoose]] == 1'b1) begin
            pcche[pc_num[`CacheChoose]] <= pc_num[`RestChoose];
            instche[pc_num[`CacheChoose]] <= inst_o;
        //    vldche[pc_num[`CacheChoose]] <= 1'b1;
            lruchoose[pc_num[`CacheChoose]] <= 1'b0;
        end else begin
            pcche1[pc_num[`CacheChoose]] <= pc_num[`RestChoose];
            instche1[pc_num[`CacheChoose]] <= inst_o;
        //    vldche1[pc_num[`CacheChoose]] <= 1'b1;
            lruchoose[pc_num[`CacheChoose]] <= 1'b1;
        end
        /*if(lruchoose[pc_num[`CacheChoose]] == 1'b1) begin
            if(pcche1[pc_num[`CacheChoose]] != pc_num) begin
                pcche[pc_num[`CacheChoose]] <= pc_num;
                instche[pc_num[`CacheChoose]] <= inst_o;
                vldche[pc_num[`CacheChoose]] <= 1'b1;
                lruchoose[pc_num[`CacheChoose]] <= 1'b0;
            end else begin
                lruchoose[pc_num[`CacheChoose]] <= 1'b1;
            end
        end else begin
            if(pcche[pc_num[`CacheChoose]] != pc_num) begin
                pcche1[pc_num[`CacheChoose]] <= pc_num;
                instche1[pc_num[`CacheChoose]] <= inst_o;
                vldche1[pc_num[`CacheChoose]] <= 1'b1;
                lruchoose[pc_num[`CacheChoose]] <= 1'b1;
            end else begin
                lruchoose[pc_num[`CacheChoose]] <= 1'b0;
            end
        end*/
    end
end

endmodule // mem_ctrl
