`include "defines.v"
module ex (
    input wire      rst,

    input wire[`InstAddrBus]    pc_i,
    input wire                  jmp_i,

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

    output reg                  b_flag_o,
    output reg[`InstAddrBus]    b_target_o,
    output reg                  is_jmp,
    output wire[`InstAddrBus]   dest,
    output reg                  jmp_res,

    output reg[`AluOpBus]       aluop_o,
    output reg[`RegBus]         mem_addr_o,
    output reg                  is_ld
    
//    output reg                  ex_stall
);

reg[`RegBus] logicout;
reg[`RegBus] shiftout;
reg[`RegBus] arithout;

wire[`InstAddrBus] tmp;
assign tmp      = reg1_i + reg2_i;
assign dest     = pc_i + offset_i;

always @ (*) begin // Branch and Jump
    b_target_o  = `ZeroWord;
    b_flag_o    = `False;
    is_jmp      = `False;
    jmp_res     = `False;
    if (rst != `RstEnable) begin
        case (aluop_i)
            `EX_JAL: begin
                is_jmp = `True;
                b_target_o  = pc_i + offset_i;
                b_flag_o    = !jmp_i;
                jmp_res     = `True;
            end
            `EX_JALR: begin
                b_target_o  = {tmp[31:1], 1'b0};
                b_flag_o    = `True;
            end
            `EX_BEQ: begin
                is_jmp = `True;
                if (reg1_i == reg2_i) begin
                    b_target_o  = pc_i + offset_i;
                    b_flag_o    = !jmp_i;
                    jmp_res     = `True;
                end else begin
                    b_target_o  = pc_i + 4;
                    b_flag_o    = jmp_i;
                end
            end
            `EX_BNE: begin
                is_jmp = `True;
                if (reg1_i != reg2_i) begin
                    b_target_o  = pc_i + offset_i;
                    b_flag_o    = !jmp_i;
                    jmp_res     = `True;
                end else begin
                    b_target_o  = pc_i + 4;
                    b_flag_o    = jmp_i;
                end
            end
            `EX_BLT: begin
                is_jmp = `True;
                if ($signed(reg1_i) < $signed(reg2_i)) begin
                    b_target_o  = pc_i + offset_i;
                    b_flag_o    = !jmp_i;
                    jmp_res     = `True;
                end else begin
                    b_target_o  = pc_i + 4;
                    b_flag_o    = jmp_i;
                end
            end
            `EX_BGE: begin
                is_jmp = `True;
                if ($signed(reg1_i) >= $signed(reg2_i)) begin
                    b_target_o  = pc_i + offset_i;
                    b_flag_o    = !jmp_i;
                    jmp_res     = `True;
                end else begin
                    b_target_o  = pc_i + 4;
                    b_flag_o    = jmp_i;
                end
            end
            `EX_BLTU: begin
                is_jmp = `True;
                if (reg1_i < reg2_i) begin
                    b_target_o  = pc_i + offset_i;
                    b_flag_o    = !jmp_i;
                    jmp_res     = `True;
                end else begin
                    b_target_o  = pc_i + 4;
                    b_flag_o    = jmp_i;
                end
            end
            `EX_BGEU: begin
                is_jmp = `True;
                if (reg1_i >= reg2_i) begin
                    b_target_o  = pc_i + offset_i;
                    b_flag_o    = !jmp_i;
                    jmp_res     = `True;
                end else begin
                    b_target_o  = pc_i + 4;
                    b_flag_o    = jmp_i;
                end
            end
            default: begin
            end
        endcase
    end
end

always @ (*) begin // Logic
    if (rst == `RstEnable) begin
        logicout = `ZeroWord;
    end else begin
        case (aluop_i)
            `EX_OR: begin
                logicout = reg1_i | reg2_i;
            end
            `EX_XOR: begin
                logicout = reg1_i ^ reg2_i;
            end
            `EX_AND: begin
                logicout = reg1_i & reg2_i;
            end
            default: begin
                logicout = `ZeroWord;
            end
        endcase
    end
end

always @ (*) begin // Shift
    if (rst == `RstEnable) begin
        shiftout = `ZeroWord;
    end else begin
        case (aluop_i)
            `EX_SLL: begin
                shiftout = reg1_i << (reg2_i[4:0]);
            end
            `EX_SRL: begin
                shiftout = reg1_i >> (reg2_i[4:0]);
            end
            `EX_SRA: begin
                shiftout = (reg1_i >> (reg2_i[4:0])) | ({32{reg1_i[31]}} << (6'd32 - {1'b0,reg2_i[4:0]}));
            end
            default: begin
                shiftout = `ZeroWord;
            end
        endcase
    end
end

always @ ( * ) begin // Arithmetic
    if(rst == `RstEnable) begin
        arithout = `ZeroWord;
    end else begin
        case(aluop_i)
            `EX_ADD: begin
                arithout = reg1_i + reg2_i;
            end
            `EX_SUB: begin
                arithout = reg1_i - reg2_i;
            end
            `EX_SLT: begin
                arithout = $signed(reg1_i) < $signed(reg2_i);
            end
            `EX_SLTU : begin
                arithout = reg1_i < reg2_i;
            end
            `EX_AUIPC: begin
                arithout = pc_i + offset_i;
            end
            default: begin
                arithout = `ZeroWord;
            end
        endcase
    end
end

always @ ( * ) begin // Load and Store
    if(rst == `RstEnable) begin
        mem_addr_o = `ZeroWord;
        is_ld = `False;
    end else begin
        case(aluop_i)
            `EX_SH, `EX_SB, `EX_SW: begin
                mem_addr_o = reg1_i + offset_i;
                is_ld = `False;
            end
            `EX_LW, `EX_LH, `EX_LB, `EX_LHU, `EX_LBU: begin
                mem_addr_o = reg1_i + offset_i;
                is_ld = `True;
            end
            default: begin
                mem_addr_o = `ZeroWord;
                is_ld = `False;
            end
        endcase
    end
end

always @ ( * ) begin // MUX
    if ((rst == `RstEnable) || (wreg_i == `True && wd_i == `NOPRegAddr)) begin
        wd_o    = `NOPRegAddr;
        wreg_o  = `False;
        wdata_o = `ZeroWord;
        aluop_o = `MEM_NOP;
    end else begin
            wd_o    = wd_i;
            wreg_o  = wreg_i;
        case (alusel_i)
            `EX_RES_JAL: begin
                wdata_o = pc_i + 4;
                aluop_o = `MEM_NOP;
            end
            `EX_RES_LOGIC: begin
                wdata_o = logicout;
                aluop_o = `MEM_NOP;
            end
            `EX_RES_SHIFT: begin
                wdata_o = shiftout;
                aluop_o = `MEM_NOP;
            end
            `EX_RES_ARITH: begin
                wdata_o = arithout;
                aluop_o = `MEM_NOP;
            end
            `EX_RES_LD_ST: begin
                wdata_o = reg2_i;
                aluop_o = aluop_i;
            end
            `EX_RES_NOP: begin
                wdata_o = `ZeroWord;
                aluop_o = `MEM_NOP;
            end
            default: begin
                wdata_o = `ZeroWord;
                aluop_o = `MEM_NOP;
            end
        endcase
    end
end

endmodule