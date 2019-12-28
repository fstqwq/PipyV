// RISCV32I CPU top module
// port modification allowed for debugging purposes
`include "defines.v"


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

wire rst;
assign rst = rst_in | (~rdy_in);


wire[`InstBus] mem_ctrl_inst;

wire[`InstAddrBus]  pc;
wire[`InstAddrBus]  id_pc_i;
wire[`InstAddrBus]  id_pc_o;
wire[`InstBus]      id_inst_i;
wire[`InstAddrBus]  ex_pc;
wire[`InstAddrBus]  inst_pc;

wire                inst_fe;
wire [`InstAddrBus] inst_fpc;

wire[`AluOpBus]     id_aluop_o;
wire[`AluSelBus]    id_alusel_o;
wire[`RegBus]       id_reg1_o;
wire[`RegBus]       id_reg2_o;
wire                id_wreg_o;
wire[`RegAddrBus]   id_wd_o;

wire[`InstAddrBus]  if_pc;
wire[`InstBus]      if_inst;

wire[`AluOpBus]     ex_aluop_i;
wire[`AluSelBus]    ex_alusel_i;
wire[`RegBus]       ex_reg1_i;
wire[`RegBus]       ex_reg2_i;
wire                ex_wreg_i;
wire[`RegAddrBus]   ex_wd_i;

wire                ex_wreg_o;
wire[`RegAddrBus]   ex_wd_o;
wire[`RegBus]       ex_wdata_o;

wire                mem_wreg_i;
wire[`RegAddrBus]   mem_wd_i;
wire[`RegBus]       mem_wdata_i;
wire                mem_wreg_o;
wire[`RegAddrBus]   mem_wd_o;
wire[`RegBus]       mem_wdata_o;

wire                wb_wreg_i;
wire[`RegAddrBus]   wb_wd_i;
wire[`RegBus]       wb_wdata_i;

wire              reg1_read;
wire              reg2_read;
wire[`RegBus]     reg1_data;
wire[`RegBus]     reg2_data;
wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;

wire[`RegBus]  ram_r_data;
wire            inquiry;
wire            ram_done;
wire            ram_sync_0;
wire            ram_sync_1;
wire            inst_ok;
wire            ram_r_req;
wire            ram_w_req;
wire[`RegBus]   ram_w_data;
wire[`RegBus]   ram_data;
wire[1:0]       ram_state;
wire[`RegBus]   ram_addr;

wire                ex_b_flag;
wire[`InstAddrBus]  ex_b_target;
wire                ex_ld_flag;

wire[`InstAddrBus]  id_offset;
wire[`InstAddrBus]  ex_offset;
wire[`RegBus]       mem_addr;
wire[`AluOpBus]     ex_aluop_o;
wire[`AluOpBus]     mem_aluop_i;
wire[`RegBus]       mem_mem_addr;

wire[`StallBus] stall_state;
wire            if_stall;
wire            id_stall;
//wire            ex_stall;
wire            mem_stall;
wire            jmp_stall;

//wire[`InstAddrBus] memctrl_pc;

regfile regfile1(
    .clk(clk_in), .rst(rst),
    .w_req(wb_wreg_i),   .w_addr(wb_wd_i),    .w_data(wb_wdata_i),
    .r1_req(reg1_read),  .r1_addr(reg1_addr), .r1_data(reg1_data),
    .r2_req(reg2_read),  .r2_addr(reg2_addr), .r2_data(reg2_data)
);

pc_reg pc_reg0 (
  .clk(clk_in), .rst(rst), .pc(pc), 
//  .id_b_flag_i(id_b_flag), .id_b_target_i(id_b_target),
  .ex_b_flag_i(ex_b_flag), .ex_b_target_i(ex_b_target),
  .stall_state(stall_state)
);

IF if0 (
  .clk(clk_in), .rst(rst), 
  .pc(pc),      .inst(mem_ctrl_inst), .inst_ok(inst_ok), .inst_pc(inst_pc),
  .pc_o(if_pc), .inst_o(if_inst),
  .inst_fe(inst_fe), .inst_fpc(inst_fpc),
  .if_stall(if_stall)
);

if_id if_id0 (
  .clk(clk_in),     .rst(rst),
  .if_pc(if_pc),       .if_inst(if_inst),
  .id_pc(id_pc_i),  .id_inst(id_inst_i),

  .ex_b_flag_i(ex_b_flag),

  .stall_state(stall_state)
);

id id0(
    .rst(rst),
    .pc_i(id_pc_i),
    .inst_i(id_inst_i),
    .reg1_data_i(reg1_data), 
    .reg2_data_i(reg2_data),

    .ex_ld_flag(ex_ld_flag),
//    .ex_b_flag(ex_b_flag),
    .ex_wreg_i(ex_wreg_o),
    .ex_wdata_i(ex_wdata_o),
    .ex_wd_i(ex_wd_o),    

    .mem_wreg_i(mem_wreg_o),
    .mem_wdata_i(mem_wdata_o),
    .mem_wd_i(mem_wd_o),

    .pc_o(id_pc_o),
    .reg1_read_o(reg1_read),  .reg1_addr_o(reg1_addr),
    .reg2_read_o(reg2_read),  .reg2_addr_o(reg2_addr),
    
    .reg1_o(id_reg1_o),       .reg2_o(id_reg2_o),
    .aluop_o(id_aluop_o),     .alusel_o(id_alusel_o),
    
    .wd_o(id_wd_o),           .wreg_o(id_wreg_o),
    .offset_o(id_offset),
//    .b_flag_o(id_b_flag),     .b_target_o(id_b_target),

    .id_stall(id_stall),
    .jmp_stall(jmp_stall)
);

id_ex id_ex0(
    .clk(clk_in),
    .rst(rst),

    .id_aluop(id_aluop_o),   .id_alusel(id_alusel_o),
    .id_reg1(id_reg1_o),     .id_reg2(id_reg2_o),
    .id_wd(id_wd_o),         .id_wreg(id_wreg_o),
    .id_pc(id_pc_o),
    .offset_i(id_offset),

//    .ex_b_flag_i(ex_b_flag),

    .ex_aluop(ex_aluop_i),   .ex_alusel(ex_alusel_i),
    .ex_reg1(ex_reg1_i),     .ex_reg2(ex_reg2_i),
    .ex_wd(ex_wd_i),         .ex_wreg(ex_wreg_i),
    .ex_pc(ex_pc),
    .offset_o(ex_offset),
    .stall_state(stall_state)
);

ex ex0(
    .rst(rst),

    .pc_i(ex_pc),
    .aluop_i(ex_aluop_i), .alusel_i(ex_alusel_i),
    .reg1_i(ex_reg1_i),   .reg2_i(ex_reg2_i),
    .wd_i(ex_wd_i),
    .wreg_i(ex_wreg_i),
    .offset_i(ex_offset),

    .wd_o(ex_wd_o),
    .wreg_o(ex_wreg_o),
    .wdata_o(ex_wdata_o),
    .b_flag_o(ex_b_flag),
    .b_target_o(ex_b_target),
    .aluop_o(ex_aluop_o),
    .mem_addr_o(mem_addr),
    
    .is_ld(ex_ld_flag)
//    ,.ex_stall(ex_stall)
);

ex_mem ex_mem0(
    .clk(clk_in),
    .rst(rst),
    
    .ex_wd(ex_wd_o),
    .ex_wreg(ex_wreg_o),
    .ex_wdata(ex_wdata_o),

    .ex_mem_addr(mem_addr),
    .ex_aluop(ex_aluop_o),

    .mem_wd(mem_wd_i),
    .mem_wreg(mem_wreg_i),
    .mem_wdata(mem_wdata_i),

    .mem_mem_addr(mem_mem_addr),
    .mem_aluop(mem_aluop_i),

    .stall_state(stall_state)
);


mem mem0(
    .rst(rst),

    .wd_i(mem_wd_i),
    .wreg_i(mem_wreg_i),
    .wdata_i(mem_wdata_i),
    .aluop_i(mem_aluop_i),
    .addr_i(mem_mem_addr),

    .wd_o(mem_wd_o),
    .wreg_o(mem_wreg_o),
    .wdata_o(mem_wdata_o),


    .ram_done_i(ram_done),
    .ram_r_data_i(ram_r_data),

    .ram_r_req_o(ram_r_req),
    .ram_w_req_o(ram_w_req),
    .ram_addr_o(ram_addr),
    .ram_w_data_o(ram_w_data),
    .ram_state(ram_state),

    .mem_stall(mem_stall)
);

mem_ctrl mem_ctrl0(
    .clk(clk_in),
    .rst(rst),

    .ram_r_req_i(ram_r_req),
    .ram_w_req_i(ram_w_req),
    .ram_addr_i(ram_addr),
    .ram_data_i(ram_w_data),
    .ram_state_i(ram_state),


    .inst_fe(inst_fe),
    .inst_fpc(inst_fpc),
    .inst_o(mem_ctrl_inst),
    .inst_pc(inst_pc),
    .ram_data_o(ram_r_data),

    .cpu_din(mem_din),
    .cpu_dout(mem_dout),
    .cpu_mem_wr(mem_wr),
    .cpu_mem_a(mem_a),

    .ram_done_o(ram_done),
    .inst_ok(inst_ok)

//    .mctl_stall(mctl_stall)

);

mem_wb mem_Wb0(
    .clk(clk_in),
    .rst(rst),

    .mem_wd(mem_wd_o),
    .mem_wreg(mem_wreg_o),
    .mem_wdata(mem_wdata_o),

    .stall_state(stall_state),
    
    .wb_wd(wb_wd_i),
    .wb_wreg(wb_wreg_i),
    .wb_wdata(wb_wdata_i)
);

stall stall0 (
  .rst(rst),

  .if_stall(if_stall),
  .id_stall(id_stall),
//  .ex_stall(ex_stall),
  .mem_stall(mem_stall),
  .jmp_stall(jmp_stall),
//  .mctl_stall(mctl_stall),
  .stall_state(stall_state)
);
/*
always @(posedge clk_in)
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