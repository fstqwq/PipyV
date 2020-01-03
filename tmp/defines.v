`ifndef hasDefined
`define hasDefined

`define RstEnable           1'b1
`define RstDisable          1'b0
`define ZeroWord            32'h00000000
`define Read                1'b0
`define Write               1'b1
`define AluOpBus            4:0
`define AluSelBus           2:0
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

`define True                1'b1
`define False               1'b0

`define AUIPC       7'b0010111
`define LUI         7'b0110111
`define OP          7'b0110011
`define OPI         7'b0010011
`define JAL         7'b1101111
`define JALR        7'b1100111
`define LOAD        7'b0000011
`define STORE       7'b0100011
`define BRANCH      7'b1100011

`define F3_BEQ   3'b000
`define F3_BNE   3'b001
`define F3_BLT   3'b100
`define F3_BGE   3'b101
`define F3_BLTU  3'b110
`define F3_BGEU  3'b111

`define F3_LB    3'b000
`define F3_LH    3'b001
`define F3_LW    3'b010
`define F3_LBU   3'b100
`define F3_LHU   3'b101

`define F3_SB    3'b000
`define F3_SH    3'b001
`define F3_SW    3'b010

`define F3_ADD   3'b000
`define F3_SUB   3'b000
`define F3_SLL   3'b001
`define F3_SLT   3'b010
`define F3_SLTU  3'b011
`define F3_XOR   3'b100
`define F3_SRL   3'b101
`define F3_SRA   3'b101
`define F3_OR    3'b110
`define F3_AND   3'b111

`define F3_ADDI  3'b000
`define F3_SLTI  3'b010
`define F3_SLTIU 3'b011
`define F3_XORI  3'b100
`define F3_ORI   3'b110
`define F3_ANDI  3'b111
`define F3_SLLI  3'b001
`define F3_SRLI  3'b101
`define F3_SRAI  3'b101

`define F7_SLLI 7'b0000000
`define F7_SRLI 7'b0000000
`define F7_SRAI 7'b0100000
`define F7_ADD 7'b0000000
`define F7_SUB 7'b0100000
`define F7_SLL 7'b0000000
`define F7_SLT 7'b0000000
`define F7_SLTU 7'b0000000
`define F7_XOR 7'b0000000
`define F7_SRL 7'b0000000
`define F7_SRA 7'b0100000
`define F7_OR 7'b0000000
`define F7_AND 7'b0000000

`define EX_NOP   5'h0
`define EX_ADD   5'h1
`define EX_SUB   5'h2
`define EX_SLT   5'h3
`define EX_SLTU  5'h4
`define EX_XOR   5'h5
`define EX_OR    5'h6
`define EX_AND   5'h7
`define EX_SLL   5'h8
`define EX_SRL   5'h9
`define EX_SRA   5'ha
`define EX_AUIPC 5'hb

`define EX_JAL   5'hc
`define EX_JALR  5'hd
`define EX_BEQ   5'he
`define EX_BNE   5'hf
`define EX_BLT   5'h10
`define EX_BGE   5'h11
`define EX_BLTU  5'h12
`define EX_BGEU  5'h13

`define EX_LB    5'h14
`define EX_LH    5'h15
`define EX_LW    5'h16
`define EX_LBU   5'h17
`define EX_LHU   5'h18

`define EX_SB    5'h19
`define EX_SH    5'h1a
`define EX_SW    5'h1b

`define MEM_NOP   5'h0

`define EX_RES_NOP      3'b000
`define EX_RES_LOGIC    3'b001
`define EX_RES_SHIFT    3'b010
`define EX_RES_ARITH    3'b011
`define EX_RES_JAL      3'b100
`define EX_RES_LD_ST    3'b101
`define EX_RES_NOP      3'b000

`define InstAddrBus     31:0
`define InstBus         31:0
`define MemBus          31:0

`define IndexBus        9:2
`define IndexSize       256
`define TagBus          7:0
`define TagBits         17:10
`define ValidBit        7

`define SCacheTag       16:7
`define SCacheId        10'h3ff
`define SCacheIndex     6:0
`define SCacheSize      128

`define PIndexBus       8:2
`define PIndexSize      128
`define PTagBus         8:0
`define PTagBits        17:9
`define PValidBit       8

`define INSR            2'b01
`define RAMO            2'b10
`define HCIO            2'b11
`define NONE            2'b00

`define NoStall         6'b000000
`define JmpStall        6'b000011
`define IfStall         6'b000011
`define IdStall         6'b000111
`define ExStall         6'b001111
`define MemStall        6'b011111
`define AllStall        6'b111111
`define StallBus        5:0
`define RamBus          7:0

`define RegNum          32
`define RegNumLog2      5
`define RegWidth        32
`define RegAddrBus      4:0
`define RegBus          31:0
`define NOPRegAddr      5'b00000


`endif
