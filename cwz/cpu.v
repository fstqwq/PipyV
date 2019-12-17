// RISCV32I CPU top module
// port modification allowed for debugging purposes
`include "defines.vh"

module cpu(
    input  wire                 clk_in,			// system clock signal
    input  wire                 rst_in,			// reset signal
	  input  wire					        rdy_in,			// ready signal, pause cpu when low

    input  wire [ 7:0]          mem_din,		// data input bus
    output wire [ 7:0]          mem_dout,		// data output bus
    output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
    output wire                 mem_wr,			// write/read signal (1 for write)

	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)
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

wire dbgrst;
assign dbgrst = rst_in | (~rdy_in);


wire[`InstAddrBus] pc;
wire[`InstAddrBus] id_pc_i;
wire [`InstBus] id_inst_i;

wire[`AluOpBus] id_aluop_o;
wire[`AluSelBus] id_alusel_o;
wire[`RegBus] id_reg1_o;
wire[`RegBus] id_reg2_o;
wire id_wreg_o;
wire[`RegAddrBus] id_wd_o;

wire[`AluOpBus] ex_aluop_i;
wire[`AluSelBus] ex_alusel_i;
wire[`RegBus] ex_reg1_i;
wire[`RegBus] ex_reg2_i;
wire ex_wreg_i;
wire[`RegAddrBus] ex_wd_i;

wire ex_wreg_o;
wire[`RegAddrBus] ex_wd_o;
wire[`RegBus] ex_wdata_o;

wire mem_wreg_i;
wire[`RegAddrBus] mem_wd_i;
wire[`RegBus] mem_wdata_i;

wire mem_wreg_o;
wire[`RegAddrBus] mem_wd_o;
wire[`RegBus] mem_wdata_o;

wire wb_wreg_i;
wire[`RegAddrBus] wb_wd_i;
wire[`RegBus] wb_wdata_i;

wire reg1_read;
wire reg2_read;
wire[`RegBus] reg1_data;
wire[`RegBus] reg2_data;
wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;

wire id_b_flag;
wire[`InstAddrBus] id_b_target;
wire ex_b_flag;
wire[`InstAddrBus] ex_b_target;
wire[`StallBus] stall;

wire[`InstAddrBus] id_pc_o;
wire ram_r_enable;
wire ram_w_enable;
wire[1:0] ram_mask;
wire if_stall_req;
wire id_stall_req;
wire ex_stall_req;
wire me_stall_req;

wire[`InstBus] rom_data_i;
wire ram_busy;
wire ram_done;
wire pc_done;
wire[`RegBus] ram_r_data;
wire[`MemBus] ram_data;
wire[`RegBus]   ram_addr;

wire[`InstAddrBus] id_offset;
wire[`InstAddrBus] ex_offset;
wire[`InstAddrBus] ex_pc_i;
wire[`RegBus] mem_addr;
wire[`AluOpBus] ex_aluop_o;
wire[`AluOpBus] me_aluop_i;
wire[`RegBus] me_mem_addr;
wire[`InstBus] if_inst;

wire[`InstAddrBus] mectrl_pc;
wire[`InstAddrBus] if_pc;

wire ex_ld_flag;

assign dbgreg_dout = pc;

`define clk_in clk

stall_ctrl stall_ctrl0(
    .rst(rst_in),
    .rdy_in(rdy_in),
    .if_stall_req(if_stall_req),
    .id_stall_req(id_stall_req),
    .ex_stall_req(ex_stall_req),
    .me_stall_req(me_stall_req),

    .stall(stall)
);

pc_reg pc_reg0(
    .clk(clk_in), .rst(rst_in), .pc(pc),
    //.ce(rom_ce_o),
    .stall(stall) ,.id_b_flag_i(id_b_flag), .id_b_target_i(id_b_target), .ex_b_flag_i(ex_b_flag), .ex_b_target_i(ex_b_target)
);

mem_ctrl mem_ctrl0(
    .clk(clk_in),
    .rst(rst_in),
    .ram_addr_i(ram_addr),
    .ram_data_i(ram_data),
    .ram_r_enable_i(ram_r_enable),
    .ram_w_enable_i(ram_w_enable),
    .ram_mask_i(ram_mask),
    .pc(pc),
    .rdy_in(rdy_in),
    .din(mem_din),
//    .stall(stall),
    .cpu_wr(mem_wr),
    .ram_busy(ram_busy),
    .ram_done(ram_done),
    .pc_done(pc_done),
    .ram_addr_o(mem_a),
    .ram_r_data_o(ram_r_data),
    .cpu_data_o(mem_dout),
    .pc_num(mectrl_pc),
    .inst_o(rom_data_i)
);

IF if0(
    .rst(rst_in),
    .pc(mectrl_pc),
    .inst(rom_data_i),
    .pc_done(pc_done),
    .pc_o(if_pc),
    .inst_o(if_inst),
    .stall_req_o(if_stall_req)
);
//assign rom_addr_o = pc;

if_id if_id0(
    .clk(clk_in),
    .rst(rst_in),
    .if_pc(if_pc),
    .if_inst(if_inst),
    .id_pc(id_pc_i),
    .id_inst(id_inst_i),
    .id_b_flag_i(id_b_flag),
    .ex_b_flag_i(ex_b_flag),
    .stall(stall)
);

id id0(
    .rst(rst_in),
    .pc_i(id_pc_i),
    .inst_i(id_inst_i),
    .reg1_data_i(reg1_data),
    .reg2_data_i(reg2_data),

    .ex_ld_flag(ex_ld_flag),
    .ex_wreg_i(ex_wreg_o),
    .ex_wdata_i(ex_wdata_o),
    .ex_wd_i(ex_wd_o),

    .mem_wreg_i(mem_wreg_o),
    .mem_wdata_i(mem_wdata_o),
    .mem_wd_i(mem_wd_o),

    .pc_o(id_pc_o),

    .reg1_read_o(reg1_read),
    .reg2_read_o(reg2_read),

    .reg1_addr_o(reg1_addr),
    .reg2_addr_o(reg2_addr),

    .aluop_o(id_aluop_o),
    .alusel_o(id_alusel_o),
    .reg1_o(id_reg1_o),
    .reg2_o(id_reg2_o),
    .wd_o(id_wd_o),
    .wreg_o(id_wreg_o),

    .offset_o(id_offset),

    .b_flag_o(id_b_flag),
    .b_target_o(id_b_target),
    .stall_req_o(id_stall_req)
);

regfile regfile1(
    .clk(clk_in),
    .rst(rst_in),
    .we(wb_wreg_i),
    .waddr(wb_wd_i),
    .wdata(wb_wdata_i),
    .re1(reg1_read),
    .raddr1(reg1_addr),
    .rdata1(reg1_data),
    .re2(reg2_read),
    .raddr2(reg2_addr),
    .rdata2(reg2_data)
);

id_ex id_ex0(
    .clk(clk_in),
    .rst(rst_in),
    .id_aluop(id_aluop_o),
    .id_alusel(id_alusel_o),
    .id_reg1(id_reg1_o),
    .id_reg2(id_reg2_o),
    .id_wd(id_wd_o),
    .id_wreg(id_wreg_o),
    .id_pc(id_pc_o),
    .id_offset(id_offset),
    .stall(stall),
    .ex_b_flag_i(ex_b_flag),
    .ex_aluop(ex_aluop_i),
    .ex_alusel(ex_alusel_i),
    .ex_reg1(ex_reg1_i),
    .ex_reg2(ex_reg2_i),
    .ex_wd(ex_wd_i),
    .ex_wreg(ex_wreg_i),
    .ex_pc(ex_pc_i),
    .ex_offset(ex_offset)
);

ex ex0(
    .rst(rst_in),
    .pc_i(ex_pc_i),
    .aluop_i(ex_aluop_i),
    .alusel_i(ex_alusel_i),
    .reg1_i(ex_reg1_i),
    .reg2_i(ex_reg2_i),
    .wd_i(ex_wd_i),
    .wreg_i(ex_wreg_i),

    .offset_i(ex_offset),

    .wd_o(ex_wd_o),
    .wreg_o(ex_wreg_o),
    .wdata_o(ex_wdata_o),
    .stall_req_o(ex_stall_req),
    .b_flag_o(ex_b_flag),
    .b_target_o(ex_b_target),
    .aluop_o(ex_aluop_o),
    .mem_addr_o(mem_addr),
    .is_ld(ex_ld_flag)
);

ex_mem ex_mem0(
    .clk(clk_in),
    .rst(rst_in),
    .ex_wd(ex_wd_o),
    .ex_wreg(ex_wreg_o),
    .ex_wdata(ex_wdata_o),

    .ex_mem_addr(mem_addr),
    .ex_aluop(ex_aluop_o),
    .stall(stall),

    .mem_wd(mem_wd_i),
    .mem_wreg(mem_wreg_i),
    .mem_wdata(mem_wdata_i),
    .mem_mem_addr(me_mem_addr),
    .mem_aluop(me_aluop_i)
);

mem mem0(
    .rst(rst_in),
    .wd_i(mem_wd_i),
    .wreg_i(mem_wreg_i),
    .wdata_i(mem_wdata_i),

    .aluop_i(me_aluop_i),
    //.mem_addr_i(me_mem_addr),

    .ram_r_data_i(ram_r_data),
    .ram_addr_i(me_mem_addr),
    .ram_done(ram_done),
    .ram_busy(ram_busy),


    .wd_o(mem_wd_o),
    .wreg_o(mem_wreg_o),
    .wdata_o(mem_wdata_o),
    .stall_req_o(me_stall_req),
    .ram_r_enable_o(ram_r_enable),
    .ram_addr_o(ram_addr),
    .ram_w_enable_o(ram_w_enable),
    .ram_w_data_o(ram_data),
    .ram_mask_o(ram_mask)
);

mem_wb mem_wb0(
    .clk(clk_in),
    .rst(rst_in),
    .mem_wd(mem_wd_o),
    .mem_wreg(mem_wreg_o),
    .mem_wdata(mem_wdata_o),
    .stall(stall),
    .wb_wd(wb_wd_i),
    .wb_wreg(wb_wreg_i),
    .wb_wdata(wb_wdata_i)
);

`undef clk_in

/*always @(posedge clk_in)
  begin
    if (rst_in)
      begin

      end
    else if (!rdy_in)
      begin

      end
    else
      begin

      end
  end
*/

endmodule
