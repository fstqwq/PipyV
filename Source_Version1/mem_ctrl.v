module mem_ctrl (
    input wire clk,
    input wire rst,
    input wire rdy_in,
    
    input wire                  ram_r_req_i,
    input wire                  ram_w_req_i,
    input wire[`MemBus]         ram_addr_i,
    input wire[`RegBus]         ram_data_i,
    input wire[1:0]             ram_state_i,
    
    output reg[`InstBus]        inst_o,
    output reg[`InstAddrBus]    inst_pc,

    output reg[`RegBus]         ram_data_o,

    input wire[`InstAddrBus]    pc,
    input wire[`RamBus]         cpu_din,

    output reg[`RamBus]         cpu_dout,
    output reg[`MemBus]         cpu_mem_a,
    output reg                  cpu_mem_wr,

    input wire                  ram_sync_i,
    output wire                 ram_busy_o,
    output reg                  ram_sync_o,
    output reg                  inst_ok
//    output reg                  mctl_stall
);

/*
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
*/

/*
[3]
if in an unfinished
[2]
0 : read
1 : write
[1:0]
0~3: recieved 0~3 bytes
*/

reg[3:0]        stage;
reg[1:0]        type;
reg[`MemBus]    ram_addr;
reg[`MemBus]    ram_data;
reg             res_rdy;


assign ram_busy_o = stage[3];
/*
    Implement a cache for instructions.
    2-way, lru
    [17 : 7][6 : 2][1 : 0]
    Tag     Index  Offset
*/
reg[`CacheBus]  tag0[`IndexSize - 1:0];
reg[`InstBus]   ins0[`IndexSize - 1:0];
reg[`CacheBus]  tag1[`IndexSize - 1:0];
reg[`InstBus]   ins1[`IndexSize - 1:0];
reg             lrut[`IndexSize - 1:0];       
wire            cachehit;

assign          cachehit = (tag0[pc[`IndexBus]] == pc[`TagBus]) | (tag1[pc[`IndexBus]] == pc[`TagBus]);

always @ (negedge clk) begin
    if (rst == `RstEnable) begin
        stage       <= 4'h0;
        ram_addr    <= `ZeroWord;
        ram_data    <= `ZeroWord;
        cpu_mem_a   <= `ZeroWord;
        cpu_mem_wr  <= `Read;
        res_rdy     <= `False;
        type        <= `NONE;
//        mctl_stall  <= `False;
    end else if (rdy_in == `False) begin
        stage       <= 4'h0;
        ram_addr    <= `ZeroWord;
        ram_data    <= `ZeroWord;
        cpu_mem_a   <= `ZeroWord;
        cpu_mem_wr  <= `Read;
        res_rdy     <= `False;
        type        <= `NONE;
//        mctl_stall  <= `False;
    end else if (stage[3] == `True && stage[2] == `Read) begin // Reading
//        mctl_stall  <= `True;
//        $display("reading, stage : %d%d%d%d", stage[3], stage[2], stage[1], stage[0]);
        case (stage[1:0])
            2'h3: begin
                ram_data[31:24] <= cpu_din;
                cpu_mem_a       <= ram_addr + 2;
                cpu_mem_wr      <= `Read;
                stage[1:0]      <= 2'h2;
                res_rdy         <= `False;
            end
            2'h2: begin
                ram_data[23:16] <= cpu_din;
                cpu_mem_a       <= ram_addr + 1;
                cpu_mem_wr      <= `Read;
                stage[1:0]      <= 2'h1;
                res_rdy         <= `False;
            end
            2'h1: begin
                ram_data[15:8]  <= cpu_din;
                cpu_mem_a       <= ram_addr + 0;
                cpu_mem_wr      <= `Read;
                stage[1:0]      <= 2'h0;
                res_rdy         <= `False;
            end
            2'h0: begin
                ram_data[7:0]   <= cpu_din;
                stage[3:0]      <= 4'h0;
                res_rdy         <= `True;
            end
        endcase
    end else if (stage[3] == `True && stage[2] == `Write) begin // Writing
//        mctl_stall  <= `True;
        case (stage[1:0])
            2'h3: begin
                cpu_dout    <= ram_data[23:16];
                cpu_mem_a   <= ram_addr + 2;
                cpu_mem_wr  <= `Write;
                stage[1:0]  <= 2'h2;
                res_rdy     <= `False;
            end
            2'h2: begin
                cpu_dout    <= ram_data[15:8];
                cpu_mem_a   <= ram_addr + 1;
                cpu_mem_wr  <= `Write;
                stage[1:0]  <= 2'h1;
                res_rdy     <= `False;
            end
            2'h1: begin
                cpu_dout    <= ram_data[7:0];
                cpu_mem_a   <= ram_addr + 0;
                cpu_mem_wr  <= `Write;
                stage[3:0]  <= 4'h0;
                res_rdy     <= `True;
            end
        endcase
    end else if (ram_sync_i != ram_sync_o && stage[3] == `False && ram_r_req_i == `True) begin
//            $display("R: %h %h", ram_addr_i, ram_state_i);
//        $display("memctl: LOAD %h", ram_addr_i);
        ram_addr    <= ram_addr_i;
        stage[3:0]  <= {2'b10,ram_state_i};
        cpu_mem_a   <= ram_addr_i + ram_state_i;
        cpu_mem_wr  <= `Read;
        res_rdy     <= `False;
//        mctl_stall  <= `True;
        type        <= `RAMR;
    end else if (ram_sync_i != ram_sync_o && stage[3] == `False && ram_w_req_i == `True) begin
//            $display("W: %h %h", ram_addr_i, ram_state_i);
        ram_addr    <= ram_addr_i;
        ram_data    <= ram_data_i;
        cpu_mem_a   <= ram_addr_i + ram_state_i;
        cpu_mem_wr  <= `Write;
        res_rdy     <= `False;
//        mctl_stall  <= `True;
        type        <= `RAMW;
        case (ram_state_i)
            4'h3: begin
                cpu_dout    <= ram_data_i[31:24];
                stage[3:0]  <= 4'b1111;
            end
            4'h1: begin
                cpu_dout    <= ram_data_i[15:8];
                stage[3:0]  <= 4'b1101;
            end
            4'h0: begin
//                $display("write %d", ram_data_i[7:0]);
                cpu_dout    <= ram_data_i[7:0];
                res_rdy     <= `True;
                stage[3:0]  <= 4'h0;
            end
        endcase
    end else if (cachehit == `False) begin // IF
//        $display("start fetch %d", pc);
        ram_addr    <= pc;
        stage[3:0]  <= 4'b1011;
        cpu_mem_a   <= pc + 3;
        cpu_mem_wr  <= `Read;
        res_rdy     <= `False;
//        mctl_stall  <= `False;
        type        <= `INSR;
    end else begin
//        mctl_stall  <= `False;
//        $display("nothing to do %d", pc);
    end
end

integer i, j;

always @ (posedge rst or posedge res_rdy) begin
    if (rst == `RstEnable) begin
        ram_sync_o  = 1'b0;
        ram_data_o  = `ZeroWord;
    end else if (res_rdy == `True && (type == `RAMR || type == `RAMW)) begin
        ram_sync_o  = !ram_sync_o;
        ram_data_o  = ram_data;
    end
end

//assign          cachehit = (tag0[pc[`IndexBus]] == pc[`TagBus]) | (tag1[pc[`IndexBus]] == pc[`TagBus]);


always @ (*) begin
    if (rst == `RstEnable) begin
        inst_ok     = `False;
        inst_pc     = `ZeroWord;
        inst_o      = `ZeroWord;
        for (j = 0; j < `IndexSize; j = j + 1) begin
            lrut[j] <= 1'b0;
        end
    end /*else if (stage[3] == `True) begin // disable cache
        inst_ok     = `False;
        inst_pc     = `ZeroWord;
        inst_o      = `ZeroWord;
        for (j = 0; j < `IndexSize; j = j + 1) begin
            lrut[j] <= 1'b0;
        end
    end */ else if (tag0[pc[`IndexBus]] == pc[`TagBus]) begin
        inst_o  = ins0[pc[`IndexBus]];
        lrut[pc[`TagBus]]   = 1'b1;
        inst_ok             = `True;
        inst_pc             = pc;
//        $display("mctl pc = %h", pc);
    end else if (tag1[pc[`IndexBus]] == pc[`TagBus]) begin
        inst_o  = ins1[pc[`IndexBus]];
        lrut[pc[`TagBus]]   = 1'b0;
        inst_ok             = `True;
        inst_pc             = pc;
//        $display("mctl pc = %h", pc);
    end else begin
        inst_ok     = `False;
        inst_o      = `ZeroWord;
        inst_pc     = `ZeroWord;
    end
end

always @ (posedge clk) begin // refresh cache 
//    $display("ref %d", j);
//    j = j + 1;
    if (rst == `RstEnable) begin
        for (i = 0; i < `IndexSize; i = i + 1) begin
            tag0[i] <= `CacheNAN;
            tag1[i] <= `CacheNAN;
            ins0[i] <= `ZeroWord;
            ins1[i] <= `ZeroWord;
        end
    end /*else if (stage[3] == `True) begin // disable cache
        for (i = 0; i < `IndexSize; i = i + 1) begin
            tag0[i] <= `CacheNAN;
            tag1[i] <= `CacheNAN;
            ins0[i] <= `ZeroWord;
            ins1[i] <= `ZeroWord;
        end
    end */else if (res_rdy == `True && type == `INSR) begin
//       $display("Cache refresh [%h %h]", ram_addr, ram_data);
        if (lrut[ram_addr[`IndexBus]] == 1'b0) begin
            tag0[ram_addr[`IndexBus]] <= ram_addr[`TagBus];
            ins0[ram_addr[`IndexBus]] <= ram_data;
        end else if (lrut[ram_addr[`IndexBus]] == 1'b1) begin
            tag1[ram_addr[`IndexBus]] <= ram_addr[`TagBus];
            ins1[ram_addr[`IndexBus]] <= ram_data;
        end
    end
end

endmodule