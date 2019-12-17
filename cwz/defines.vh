`ifndef _DEFINES
`define _DEFINES

//---------------------Reg ---------------------------------------
`define RegNum          32
`define RegNumLog2      5
`define RegWidth        32
`define RegAddrBus      4:0
`define RegBus          31:0
`define NOPRegAddr      5'b00000

//--------------------General ---------------------------
`define RstEnable           1'b1
`define RstDisable          1'b0
`define ZeroWord            32'h00000000
`define WriteEnable         1'b1
`define WriteDisable        1'b0
`define ReadEnable          1'b1
`define ReadDisable         1'b0
`define AluOpBus            5:0
`define AluSelBus           2:0
`define Instvalid           1'b0
`define InstInvalid         1'b1
`define Stop                1'b1
`define NoStop              1'b0
`define IndelaySlot         1'b1
`define NotInDelaySlot      1'b0
`define Branch              1'b1
`define NotBranch           1'b0
`define InterruptAssert     1'b1
`define InterruptNoptAssert 1'b0
`define ChipsEnable         1'b1
`define ChipsDisable        1'b0

//-------------------- Opcode -----------------------------------
`define OpOPI       7'b0010011
`define OpJAL       7'b1101111
`define OpJALR      7'b1100111
`define OpLOAD      7'b0000011
`define OpSTORE     7'b0100011
`define OpBRANCH    7'b1100011
`define OpOP        7'b0110011
`define OpLUI       7'b0110111
`define OPAUIPC     7'b0010111



//----------------------funct3--------------------------------------
//branch
`define Funct3BEQ   3'b000
`define Funct3BNE   3'b001
`define Funct3BLT   3'b100
`define Funct3BGE   3'b101
`define Funct3BLTU  3'b110
`define Funct3BGEU  3'b111
//load
`define Funct3LB    3'b000
`define Funct3LH    3'b001
`define Funct3LW    3'b010
`define Funct3LBU   3'b100
`define Funct3LHU   3'b101
//store
`define Funct3SB    3'b000
`define Funct3SH    3'b001
`define Funct3SW    3'b010
//op
`define Funct3ADD   3'b000
`define Funct3SUB   3'b000
`define Funct3SLL   3'b001
`define Funct3SLT   3'b010
`define Funct3SLTU  3'b011
`define Funct3XOR   3'b100
`define Funct3SRL   3'b101
`define Funct3SRA   3'b101
`define Funct3OR    3'b110
`define Funct3AND   3'b111
//opi
`define Funct3ADDI  3'b000
`define Funct3SLTI  3'b010
`define Funct3SLTIU 3'b011
`define Funct3XORI  3'b100
`define Funct3ORI   3'b110
`define Funct3ANDI  3'b111
`define Funct3SLLI  3'b001
`define Funct3SRLI  3'b101
`define Funct3SRAI  3'b101

//----------------------Funct7----------------------------------
`define Funct7SLLI 7'b0000000
`define Funct7SRLI 7'b0000000
`define Funct7SRAI 7'b0100000
`define Funct7ADD 7'b0000000
`define Funct7SUB 7'b0100000
`define Funct7SLL 7'b0000000
`define Funct7SLT 7'b0000000
`define Funct7SLTU 7'b0000000
`define Funct7XOR 7'b0000000
`define Funct7SRL 7'b0000000
`define Funct7SRA 7'b0100000
`define Funct7OR 7'b0000000
`define Funct7AND 7'b0000000

//----------------------Alu ------------------------------------
// alu coding refering Michaelvll (Zhanghao Wu)

`define EX_NOP_OP   5'h0
`define EX_ADD_OP   5'h1
`define EX_SUB_OP   5'h2
`define EX_SLT_OP   5'h3
`define EX_SLTU_OP  5'h4
`define EX_XOR_OP   5'h5
`define EX_OR_OP    5'h6
`define EX_AND_OP   5'h7
`define EX_SLL_OP   5'h8
`define EX_SRL_OP   5'h9
`define EX_SRA_OP   5'ha
`define EX_AUIPC_OP 5'hb

`define EX_JAL_OP   5'hc
`define EX_JALR_OP  5'hd
`define EX_BEQ_OP   5'he
`define EX_BNE_OP   5'hf
`define EX_BLT_OP   5'h10
`define EX_BGE_OP   5'h11
`define EX_BLTU_OP  5'h12
`define EX_BGEU_OP  5'h13

`define EX_LB_OP    5'h14
`define EX_LH_OP    5'h15
`define EX_LW_OP    5'h16
`define EX_LBU_OP   5'h17
`define EX_LHU_OP   5'h18

`define EX_SB_OP    5'h19
`define EX_SH_OP    5'h1a
`define EX_SW_OP    5'h1b

`define ME_NOP_OP   5'h0

//----------------------Alu Sel----------------------------------
`define EX_RES_NOP      3'b000
`define EX_RES_LOGIC    3'b001
`define EX_RES_SHIFT    3'b010
`define EX_RES_ARITH    3'b011
`define EX_RES_JAL      3'b100
`define EX_RES_LD_ST    3'b101
`define EX_RES_NOP      3'b000

//----------------------MemBus-----------------------------------
`define InstAddrBus     31:0
`define InstBus         31:0
`define MemBus          31:0
`define CacheSize       32
`define CacheBus        10:0
`define RestChoose      17:7
`define CacheChoose     6:2
`define CacheClear      11'b11000000000

//---------------------Stall -------------------------------------
`define StallReq        1'b1
`define StallNotReq     1'b0
`define NoStall         6'b000000
`define IfStall         6'b000011
`define IdStall         6'b000111
`define ExStall         6'b001111
`define MemStall        6'b011111
`define AllStall        6'b111111
//`define WbStall         6'b111111
`define StallBus        5:0

`endif
