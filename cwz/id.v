`include "defines.vh"
module id (
    input wire                  rst,
    input wire[`InstAddrBus]    pc_i,
    input wire[`InstBus]        inst_i,

    input wire[`RegBus]         reg1_data_i,
    input wire[`RegBus]         reg2_data_i,

    input wire                  ex_ld_flag,
    input wire                  ex_wreg_i,
    input wire[`RegBus]         ex_wdata_i,
    input wire[`RegAddrBus]     ex_wd_i,

    input wire                  mem_wreg_i,
    input wire[`RegBus]         mem_wdata_i,
    input wire[`RegAddrBus]     mem_wd_i,

    output reg[`InstAddrBus]    pc_o,

    output reg                  reg1_read_o,
    output reg                  reg2_read_o,
    output reg[`RegAddrBus]     reg1_addr_o,
    output reg[`RegAddrBus]     reg2_addr_o,

    output reg[`AluOpBus]       aluop_o,
    output reg[`AluSelBus]      alusel_o,
    output reg[`RegBus]         reg1_o,
    output reg[`RegBus]         reg2_o,
    output reg[`RegAddrBus]     wd_o,
    output reg                  wreg_o,

    output reg[`RegBus]         offset_o,

    output reg                  b_flag_o,
    output reg[`InstAddrBus]    b_target_o,
    output wire                 stall_req_o
);

wire[6:0] opcode =  inst_i[6:0];
wire[4:0] rd =      inst_i[11:7];
wire[3:0] funct3 =  inst_i[14:12];
wire[4:0] rs1 =     inst_i[19:15];
wire[4:0] rs2 =     inst_i[24:20];
wire[6:0] funct7 =  inst_i[31:25];
wire[11:0] I_imm =  inst_i[31:20];
wire[11:0] S_imm =  {inst_i[31:25], inst_i[11:7]};
wire[11:0] SB_imm = {inst_i[31],inst_i[7],inst_i[30:25],inst_i[11:8]};
wire[19:0] U_imm =  inst_i[31:12];
wire[19:0] UJ_imm = {inst_i[31], inst_i[19:12],inst_i[20],inst_i[30:21]};
reg[31:0] imm;
//reg[31:0] imm2;
reg instvalid;

//----------------------------decodeing----------------------------------------
always @ ( * ) begin
    pc_o = pc_i;
    //stall_req_o = 1'b0;
    if(rst == `RstEnable) begin
        aluop_o =      `EX_NOP_OP;
        alusel_o =     `EX_RES_NOP;
        wd_o =         `NOPRegAddr;
        wreg_o =       `WriteDisable;
        instvalid =    `Instvalid;
        reg1_read_o =  1'b0;
        reg2_read_o =  1'b0;
        reg1_addr_o =  `NOPRegAddr;
        reg2_addr_o =  `NOPRegAddr;
        imm =          `ZeroWord;
        b_flag_o =     1'b0;
        b_target_o =   `ZeroWord;
    end else begin
        aluop_o =      `EX_NOP_OP;
        alusel_o =     `EX_RES_NOP;
        wd_o =         `NOPRegAddr;
        wreg_o =       `WriteDisable;
        instvalid =    `InstInvalid;
        reg1_read_o =  1'b0;
        reg2_read_o =  1'b0;
        reg1_addr_o =  `NOPRegAddr;
        reg2_addr_o =  `NOPRegAddr;
        imm =          `ZeroWord;
        b_flag_o =     1'b0;
        b_target_o =   `ZeroWord;
        case (opcode)
            `OpSTORE: begin
                case (funct3)
                    `Funct3SB: begin
                        aluop_o =      `EX_SB_OP;
                        alusel_o =     `EX_RES_LD_ST;
                        wd_o =         rd;
                        wreg_o =       `WriteDisable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b1;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          {{20{S_imm[11]}},S_imm[11:0]};
                    end
                    `Funct3SH: begin
                        aluop_o =      `EX_SH_OP;
                        alusel_o =     `EX_RES_LD_ST;
                        wd_o =         rd;
                        wreg_o =       `WriteDisable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b1;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          {{20{S_imm[11]}},S_imm[11:0]};
                    end
                    `Funct3SW: begin
                        aluop_o =      `EX_SW_OP;
                        alusel_o =     `EX_RES_LD_ST;
                        wd_o =         rd;
                        wreg_o =       `WriteDisable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b1;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          {{20{S_imm[11]}},S_imm[11:0]};
                    end
                    default: begin
                    end
                endcase
            end
            `OpLOAD: begin
                case (funct3)
                    `Funct3LB: begin
                        aluop_o =      `EX_LB_OP;
                        alusel_o =     `EX_RES_LD_ST;
                        wd_o =         rd;
                        wreg_o =       `WriteEnable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b0;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          {{20{I_imm[11]}},I_imm[11:0]};
                    end
                    `Funct3LH: begin
                        aluop_o =      `EX_LH_OP;
                        alusel_o =     `EX_RES_LD_ST;
                        wd_o =         rd;
                        wreg_o =       `WriteEnable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b0;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          {{20{I_imm[11]}},I_imm[11:0]};
                    end
                    `Funct3LW: begin
                        aluop_o =      `EX_LW_OP;
                        alusel_o =     `EX_RES_LD_ST;
                        wd_o =         rd;
                        wreg_o =       `WriteEnable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b0;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          {{20{I_imm[11]}},I_imm[11:0]};
                    end
                    `Funct3LBU: begin
                        aluop_o =      `EX_LBU_OP;
                        alusel_o =     `EX_RES_LD_ST;
                        wd_o =         rd;
                        wreg_o =       `WriteEnable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b0;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          {{20{I_imm[11]}},I_imm[11:0]};
                    end
                    `Funct3LHU: begin
                        aluop_o =      `EX_LHU_OP;
                        alusel_o =     `EX_RES_LD_ST;
                        wd_o =         rd;
                        wreg_o =       `WriteEnable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b0;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          {{20{I_imm[11]}},I_imm[11:0]};
                    end
                    default: begin
                    end
                endcase
            end
            `OpJAL: begin
                aluop_o =      `EX_JAL_OP;
                alusel_o =     `EX_RES_JAL;
                wd_o =         rd;
                wreg_o =       `WriteEnable;
                instvalid =    `Instvalid;
                reg1_read_o =  1'b0;
                reg2_read_o =  1'b0;
                reg1_addr_o =  rs1;
                reg2_addr_o =  rs2;
                imm =          {{11{UJ_imm[19]}},UJ_imm,1'h0};
                b_flag_o =     1'b1;
                b_target_o =   pc_i + {{11{UJ_imm[19]}},UJ_imm,1'h0};
            end
            `OpJALR: begin
                aluop_o =      `EX_JALR_OP;
                alusel_o =     `EX_RES_JAL;
                wd_o =         rd;
                wreg_o =       `WriteEnable;
                instvalid =    `Instvalid;
                reg1_read_o =  1'b1;
                reg2_read_o =  1'b0;
                reg1_addr_o =  rs1;
                reg2_addr_o =  rs2;
                imm =          {{20{I_imm[11]}},I_imm};
            end
            `OpBRANCH: begin
                case (funct3)
                    `Funct3BEQ: begin
                        aluop_o =      `EX_BEQ_OP;
                        alusel_o =     `EX_RES_NOP;
                        wd_o =         rd;
                        wreg_o =       `WriteDisable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b1;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          {{19{SB_imm[11]}},SB_imm, 1'b0};
                    end
                    `Funct3BNE: begin
                        aluop_o =      `EX_BNE_OP;
                        alusel_o =     `EX_RES_NOP;
                        wd_o =         rd;
                        wreg_o =       `WriteDisable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b1;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          {{19{SB_imm[11]}},SB_imm, 1'b0};
                    end
                    `Funct3BLT: begin
                        aluop_o =      `EX_BLT_OP;
                        alusel_o =     `EX_RES_NOP;
                        wd_o =         rd;
                        wreg_o =       `WriteDisable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b1;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          {{19{SB_imm[11]}},SB_imm, 1'b0};
                    end
                    `Funct3BGE: begin
                        aluop_o =      `EX_BGE_OP;
                        alusel_o =     `EX_RES_NOP;
                        wd_o =         rd;
                        wreg_o =       `WriteDisable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b1;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          {{19{SB_imm[11]}},SB_imm, 1'b0};
                    end
                    `Funct3BLTU: begin
                        aluop_o =      `EX_BLTU_OP;
                        alusel_o =     `EX_RES_NOP;
                        wd_o =         rd;
                        wreg_o =       `WriteDisable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b1;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          {{19{SB_imm[11]}},SB_imm, 1'b0};
                    end
                    `Funct3BGEU: begin
                        aluop_o =      `EX_BGEU_OP;
                        alusel_o =     `EX_RES_NOP;
                        wd_o =         rd;
                        wreg_o =       `WriteDisable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b1;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          {{19{SB_imm[11]}},SB_imm, 1'b0};
                    end
                    default: begin
                    end
                endcase
            end
            `OpLUI: begin
                aluop_o =      `EX_OR_OP;
                alusel_o =     `EX_RES_LOGIC;
                wd_o =         rd;
                wreg_o =       `WriteEnable;
                instvalid =    `Instvalid;
                reg1_read_o =  1'b0;
                reg2_read_o =  1'b0;
                reg1_addr_o =  rs1;
                reg2_addr_o =  rs2;
                imm =          {U_imm,12'h0};
            end
            `OPAUIPC: begin
                aluop_o =      `EX_AUIPC_OP;
                alusel_o =     `EX_RES_ARITH;
                wd_o =         rd;
                wreg_o =       `WriteEnable;
                instvalid =    `Instvalid;
                reg1_read_o =  1'b0;
                reg2_read_o =  1'b0;
                reg1_addr_o =  rs1;
                reg2_addr_o =  rs2;
                imm =          {U_imm,12'h0};
            end
            `OpOP: begin
                case(funct3)
                    `Funct3ADD: begin
                        case(funct7)
                            `Funct7ADD: begin
                                aluop_o =      `EX_ADD_OP;
                                alusel_o =     `EX_RES_ARITH;
                                wd_o =         rd;
                                wreg_o =       `WriteEnable;
                                instvalid =    `Instvalid;
                                reg1_read_o =  1'b1;
                                reg2_read_o =  1'b1;
                                reg1_addr_o =  rs1;
                                reg2_addr_o =  rs2;
                                imm =          `ZeroWord;
                            end
                            `Funct7SUB: begin
                                aluop_o =      `EX_SUB_OP;
                                alusel_o =     `EX_RES_ARITH;
                                wd_o =         rd;
                                wreg_o =       `WriteEnable;
                                instvalid =    `Instvalid;
                                reg1_read_o =  1'b1;
                                reg2_read_o =  1'b1;
                                reg1_addr_o =  rs1;
                                reg2_addr_o =  rs2;
                                imm =          `ZeroWord;
                            end
                            default: begin
                            end
                        endcase
                    end
                    `Funct3SLT: begin
                        aluop_o =      `EX_SLT_OP;
                        alusel_o =     `EX_RES_ARITH;
                        wd_o =         rd;
                        wreg_o =       `WriteEnable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b1;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          `ZeroWord;
                    end
                    `Funct3SLTU: begin
                        aluop_o =      `EX_SLTU_OP;
                        alusel_o =     `EX_RES_ARITH;
                        wd_o =         rd;
                        wreg_o =       `WriteEnable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b1;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          `ZeroWord;
                    end
                    `Funct3AND: begin
                        aluop_o =      `EX_AND_OP;
                        alusel_o =     `EX_RES_LOGIC;
                        wd_o =         rd;
                        wreg_o =       `WriteEnable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b1;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          `ZeroWord;
                    end
                    `Funct3OR: begin
                        aluop_o =      `EX_OR_OP;
                        alusel_o =     `EX_RES_LOGIC;
                        wd_o =         rd;
                        wreg_o =       `WriteEnable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b1;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          `ZeroWord;
                    end
                    `Funct3XOR: begin
                        aluop_o =      `EX_XOR_OP;
                        alusel_o =     `EX_RES_LOGIC;
                        wd_o =         rd;
                        wreg_o =       `WriteEnable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b1;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          `ZeroWord;
                    end
                    `Funct3SLL: begin
                        aluop_o =      `EX_SLL_OP;
                        alusel_o =     `EX_RES_SHIFT;
                        wd_o =         rd;
                        wreg_o =       `WriteEnable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b1;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          `ZeroWord;
                    end
                    `Funct3SRL: begin
                        case(funct7)
                            `Funct7SRL: begin
                                aluop_o =      `EX_SRL_OP;
                                alusel_o =     `EX_RES_SHIFT;
                                wd_o =         rd;
                                wreg_o =       `WriteEnable;
                                instvalid =    `Instvalid;
                                reg1_read_o =  1'b1;
                                reg2_read_o =  1'b1;
                                reg1_addr_o =  rs1;
                                reg2_addr_o =  rs2;
                                imm =          `ZeroWord;
                            end
                            `Funct7SRA: begin
                                aluop_o =      `EX_SRA_OP;
                                alusel_o =     `EX_RES_SHIFT;
                                wd_o =         rd;
                                wreg_o =       `WriteEnable;
                                instvalid =    `Instvalid;
                                reg1_read_o =  1'b1;
                                reg2_read_o =  1'b1;
                                reg1_addr_o =  rs1;
                                reg2_addr_o =  rs2;
                                imm =          `ZeroWord;
                            end
                            default: begin
                            end
                        endcase
                    end
                    default: begin
                    end
                endcase
            end
            `OpOPI: begin
                case(funct3)
                    `Funct3SRLI: begin
                        case(funct7)
                            `Funct7SRLI: begin
                                aluop_o =      `EX_SRL_OP;
                                alusel_o =     `EX_RES_SHIFT;
                                wd_o =         rd;
                                wreg_o =       `WriteEnable;
                                instvalid =    `Instvalid;
                                reg1_read_o =  1'b1;
                                reg2_read_o =  1'b0;
                                reg1_addr_o =  rs1;
                                reg2_addr_o =  rs2;
                                imm =          {27'h0, rs2};
                            end
                            `Funct7SRAI: begin
                                aluop_o =      `EX_SRA_OP;
                                alusel_o =     `EX_RES_SHIFT;
                                wd_o =         rd;
                                wreg_o =       `WriteEnable;
                                instvalid =    `Instvalid;
                                reg1_read_o =  1'b1;
                                reg2_read_o =  1'b0;
                                reg1_addr_o =  rs1;
                                reg2_addr_o =  rs2;
                                imm =          {27'h0, rs2};
                            end
                            default: begin
                            end
                        endcase
                    end
                    `Funct3SLLI: begin
                        aluop_o =      `EX_SLL_OP;
                        alusel_o =     `EX_RES_SHIFT;
                        wd_o =         rd;
                        wreg_o =       `WriteEnable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b0;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          {27'h0, rs2};
                    end
                    `Funct3ORI: begin
                        aluop_o =      `EX_OR_OP;
                        alusel_o =     `EX_RES_LOGIC;
                        wd_o =         rd;
                        wreg_o =       `WriteEnable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b0;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          {{20{I_imm[11]}}, I_imm[11:0]};
                    end
                    `Funct3XORI: begin
                        aluop_o =      `EX_XOR_OP;
                        alusel_o =     `EX_RES_LOGIC;
                        wd_o =         rd;
                        wreg_o =       `WriteEnable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b0;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          {{20{I_imm[11]}}, I_imm[11:0]};
                    end
                    `Funct3ANDI: begin
                        aluop_o =      `EX_AND_OP;
                        alusel_o =     `EX_RES_LOGIC;
                        wd_o =         rd;
                        wreg_o =       `WriteEnable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b0;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          {{20{I_imm[11]}}, I_imm[11:0]};
                    end
                    `Funct3ADDI: begin
                        aluop_o =      `EX_ADD_OP;
                        alusel_o =     `EX_RES_ARITH;
                        wd_o =         rd;
                        wreg_o =       `WriteEnable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b0;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          {{20{I_imm[11]}}, I_imm[11:0]};
                    end
                    `Funct3SLTI: begin
                        aluop_o =      `EX_SLT_OP;
                        alusel_o =     `EX_RES_ARITH;
                        wd_o =         rd;
                        wreg_o =       `WriteEnable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b0;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          {{20{I_imm[11]}}, I_imm[11:0]};
                    end
                    `Funct3SLTIU: begin
                        aluop_o =      `EX_SLTU_OP;
                        alusel_o =     `EX_RES_ARITH;
                        wd_o =         rd;
                        wreg_o =       `WriteEnable;
                        instvalid =    `Instvalid;
                        reg1_read_o =  1'b1;
                        reg2_read_o =  1'b0;
                        reg1_addr_o =  rs1;
                        reg2_addr_o =  rs2;
                        imm =          {{20{I_imm[11]}}, I_imm[11:0]};
                    end
                    default: begin
                    end
                endcase
            end
            default: begin
            end
        endcase
    end
end

reg r1_stall;
reg r2_stall;

always @ ( * ) begin
    if(rst == `RstEnable) begin
        reg1_o = `ZeroWord;
        r1_stall = 1'b0;
    end else if ((reg1_read_o == 1'b1) && (ex_ld_flag == 1'b1) && (ex_wd_i == reg1_addr_o)) begin
        reg1_o = `ZeroWord;
        r1_stall = 1'b1;
    end else if ((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o)) begin
        reg1_o = ex_wdata_i;
        r1_stall = 1'b0;
    end else if ((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg1_addr_o)) begin
        reg1_o = mem_wdata_i;
        r1_stall = 1'b0;
    end else if (reg1_read_o == 1'b1)  begin
        reg1_o = reg1_data_i;
        r1_stall = 1'b0;
    end else if (reg1_read_o == 1'b0) begin
        reg1_o = imm;
        r1_stall = 1'b0;
    end else begin
        reg1_o = `ZeroWord;
        r1_stall = 1'b0;
    end
end

always @ ( * ) begin
    if(rst == `RstEnable) begin
        reg2_o = `ZeroWord;
        r2_stall = 1'b0;
    end else if ((reg2_read_o == 1'b1) && (ex_ld_flag == 1'b1) && (ex_wd_i == reg2_addr_o)) begin
        reg2_o = ex_wdata_i;
        r2_stall = 1'b1;
    end else if ((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o)) begin
        reg2_o = ex_wdata_i;
        r2_stall = 1'b0;
    end else if ((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg2_addr_o)) begin
        reg2_o = mem_wdata_i;
        r2_stall = 1'b0;
    end else if (reg2_read_o == 1'b1)  begin
        reg2_o = reg2_data_i;
        r2_stall = 1'b0;
    end else if (reg2_read_o == 1'b0) begin
        reg2_o = imm;
        r2_stall = 1'b0;
    end else begin
        reg2_o = `ZeroWord;
        r2_stall = 1'b0;
    end
end
/*
always @ ( * ) begin
    stall_req_o = r1_stall | r2_stall;
end
*/

assign stall_req_o = r1_stall | r2_stall;

always @ ( * ) begin
    if(rst == `RstEnable) begin
        offset_o = `ZeroWord;
    end else begin
        offset_o = imm;
    end
end

endmodule // id
