`include "defines.vh"
module ex (
    input wire                  rst,

    input wire[`InstAddrBus]    pc_i,
    input wire[`AluOpBus]       aluop_i,
    input wire[`AluSelBus]      alusel_i,
    input wire[`RegBus]         reg1_i,
    input wire[`RegBus]         reg2_i,
    input wire[`RegAddrBus]     wd_i,
    input wire                  wreg_i,

    input wire[`RegBus]         offset_i,

    output reg[`RegAddrBus]     wd_o,
    output reg                  wreg_o,
    output reg[`RegBus]         wdata_o,
    output reg                  stall_req_o,

    output reg                  b_flag_o,
    output reg[`InstAddrBus]    b_target_o,

    output reg[`AluOpBus]       aluop_o,
    output reg[`RegBus]         mem_addr_o,
    output reg                  is_ld
);

reg[`RegBus] logicout;
reg[`RegBus] shiftout;
reg[`RegBus] arithout;
reg[`RegBus] pcout;
wire[`RegBus] sumres;

assign sumres = reg1_i + reg2_i;

always @ ( * ) begin
    stall_req_o = 1'b0;
    if(rst == `RstEnable) begin
        b_flag_o = 1'b0;
        b_target_o = `ZeroWord;
    end else begin
        case (aluop_i)
        /*    `EX_JAL_OP: begin
                b_flag_o = 1'b1;
                b_target_o = pc_i + offset_i;
            end*/
            `EX_JALR_OP: begin
                b_flag_o = 1'b1;
                //sumres = reg1_i + reg2_i;
                b_target_o = {sumres[31:1], 1'b0};
            end
            `EX_BNE_OP:  begin
                b_flag_o = ~(reg1_i == reg2_i);
                b_target_o = pc_i + offset_i;
            end
            `EX_BEQ_OP: begin
                b_flag_o = (reg1_i == reg2_i);
                b_target_o = pc_i + offset_i;
            end
            `EX_BLT_OP: begin
                b_flag_o = ($signed(reg1_i) < $signed(reg2_i));
                b_target_o = pc_i + offset_i;
            end
            `EX_BGE_OP: begin
                b_flag_o = ($signed(reg1_i) >= $signed(reg2_i));
                b_target_o = pc_i + offset_i;
            end
            `EX_BLTU_OP: begin
                b_flag_o = ((reg1_i) < (reg2_i));
                b_target_o = pc_i + offset_i;
            end
            `EX_BGEU_OP: begin
                b_flag_o = ((reg1_i) >= (reg2_i));
                b_target_o = pc_i + offset_i;
            end
            default: begin
                b_flag_o = 1'b0;
                b_target_o = `ZeroWord;
            end
        endcase
		if (b_flag_o) begin
            $display("ex: JUMP %h", b_target_o);
        end
    end
end

always @ ( * ) begin
    if(rst == `RstEnable) begin
        logicout = `ZeroWord;
    end else begin
        case (aluop_i)
            `EX_OR_OP: begin
                logicout = reg1_i | reg2_i;
            end
            `EX_XOR_OP: begin
                logicout = reg1_i ^ reg2_i;
            end
            `EX_AND_OP: begin
                logicout = reg1_i & reg2_i;
            end
            default: begin
                logicout = `ZeroWord;
            end
        endcase
    end
end

always @ ( * ) begin
    if(rst == `RstEnable) begin
        shiftout = `ZeroWord;
    end else begin
        case(aluop_i)
            `EX_SLL_OP: begin
                shiftout = reg1_i << (reg2_i[4:0]);
            end
            `EX_SRL_OP: begin
                shiftout = reg1_i >> (reg2_i[4:0]);
            end
            `EX_SRA_OP: begin
                shiftout = (reg1_i >> (reg2_i[4:0])) | ({32{reg1_i[31]}} << (6'd32 - {1'b0,reg2_i[4:0]}));
            end
            default : begin
                shiftout = `ZeroWord;
            end
        endcase
    end
end

always @ ( * ) begin
    if(rst == `RstEnable) begin
        mem_addr_o = `ZeroWord;
        is_ld = 1'b0;
    end else begin
        case(aluop_i)
        `EX_SH_OP, `EX_SB_OP, `EX_SW_OP: begin
            mem_addr_o = reg1_i + offset_i;
            is_ld = 1'b0;
        end
        `EX_LW_OP, `EX_LH_OP, `EX_LB_OP, `EX_LHU_OP, `EX_LBU_OP: begin
            mem_addr_o = reg1_i + offset_i;
            is_ld = 1'b1;
        end
        default: begin
            mem_addr_o = `ZeroWord;
            is_ld = 1'b0;
        end
        endcase
        //end
    end
end

always @ ( * ) begin
    if(rst == `RstEnable) begin
        arithout = `ZeroWord;
    end else begin
        case(aluop_i)
            `EX_ADD_OP: begin
                arithout = reg1_i + reg2_i;
            end
            `EX_SUB_OP: begin
                arithout = reg1_i - reg2_i;
            end
            `EX_SLT_OP: begin
                arithout = $signed(reg1_i) < $signed(reg2_i);
            end
            `EX_SLTU_OP : begin
                arithout = reg1_i < reg2_i;
            end
            `EX_AUIPC_OP: begin
                arithout = pc_i + offset_i;
            end
            default: begin
                arithout = `ZeroWord;
            end
        endcase
    end
end



always @ ( * ) begin
    if(wreg_i && !wd_i) begin
        wd_o = `ZeroWord;
        wreg_o = `WriteDisable;
        wdata_o = `ZeroWord;
        aluop_o = `ME_NOP_OP;
    end else begin
        wd_o = wd_i;
        wreg_o = wreg_i;
        //$display(alusel_i);
        case (alusel_i)
            `EX_RES_JAL: begin
                wdata_o = pc_i + 4;
                aluop_o = `ME_NOP_OP;
            end
            `EX_RES_LOGIC: begin
                wdata_o = logicout;
                aluop_o = `ME_NOP_OP;
            end
            `EX_RES_SHIFT: begin
                wdata_o = shiftout;
                aluop_o = `ME_NOP_OP;
            end
            `EX_RES_ARITH: begin
                wdata_o = arithout;
                aluop_o = `ME_NOP_OP;
            end
            `EX_RES_LD_ST: begin

        //        $display("hello, world!");
                aluop_o = aluop_i;
                wdata_o = reg2_i;
            end
            default: begin
                wdata_o = `ZeroWord;
                aluop_o = `ME_NOP_OP;
            end
        endcase
    end
end

endmodule // ex
