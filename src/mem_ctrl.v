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
    output reg[`RegBus]         ram_data_o,

    input wire[`InstAddrBus]    pc,
    input wire[`RamBus]         cpu_din,

    output reg[`RamBus]         cpu_dout,
    output reg[`MemBus]         cpu_mem_a,
    output reg                  cpu_mem_wr,

    input wire                  mem_ack_i,
    output wire                 ram_busy_o,
    output reg                  ram_ok,
    output reg                  inst_ok
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
    end else if (rdy_in == `False) begin
        stage       <= 4'h0;
        ram_addr    <= `ZeroWord;
        ram_data    <= `ZeroWord;
        cpu_mem_a   <= `ZeroWord;
        cpu_mem_wr  <= `Read;
        res_rdy     <= `False;
        type        <= `NONE;
    end else if (stage[3] == `True && stage[2] == `Read) begin // Reading
//        $display("reading, stage : %d%d%d%d", stage[3], stage[2], stage[1], stage[0]);
        case (stage[1:0])
            2'h3: begin
                ram_data[31:24] <= cpu_din;
                cpu_mem_a       <= ram_addr + 2;
                cpu_mem_wr      <= `Read;
                stage[1:0]      <= 2'h2;
            end
            2'h2: begin
                ram_data[23:16] <= cpu_din;
                cpu_mem_a       <= ram_addr + 1;
                cpu_mem_wr      <= `Read;
                stage[1:0]      <= 2'h1;
            end
            2'h1: begin
                ram_data[15:8]  <= cpu_din;
                cpu_mem_a       <= ram_addr + 0;
                cpu_mem_wr      <= `Read;
                stage[1:0]      <= 2'h0;
            end
            2'h0: begin
                ram_data[7:0]   <= cpu_din;
                stage[3:0]      <= 4'h0;
                res_rdy         <= `True;
            end
        endcase
    end else if (stage[3] == `True && stage[2] == `Write) begin // Writing
        case (stage[1:0])
            2'h3: begin
                cpu_dout    <= ram_data[23:16];
                cpu_mem_a   <= ram_addr + 2;
                cpu_mem_wr  <= `Write;
                stage[3:0]  <= 2'h2;
            end
            2'h2: begin
                cpu_dout    <= ram_data[15:8];
                cpu_mem_a   <= ram_addr + 1;
                cpu_mem_wr  <= `Write;
                stage[1:0]  <= 2'h1;
            end
            2'h1: begin
                cpu_dout    <= ram_data[7:0];
                cpu_mem_a   <= ram_addr + 0;
                cpu_mem_wr  <= `Write;
                stage[3:0]  <= 4'h0;
            end
        endcase
    end else if (type == `RAM && mem_ack_i == `False) begin
        // do nothing
    end else if (stage[3] == `False && ram_r_req_i == `True) begin
        ram_addr    <= ram_addr_i;
        stage[3:0]  <= {2'b10,ram_state_i};
        cpu_mem_a   <= ram_addr_i + ram_state_i;
        cpu_mem_wr  <= `Read;
        res_rdy     <= `False;
        type        <= `RAM;
    end else if (stage[3] == `False && ram_w_req_i == `True) begin
        ram_addr    <= ram_addr_i;
        ram_data    <= ram_data_i;
        stage[3:0]  <= {2'b11,ram_state_i};
        cpu_mem_a   <= ram_addr_i + ram_state_i;
        cpu_dout    <= ram_data_i[7:0];
        cpu_mem_wr  <= `Write;
        res_rdy     <= `False;
        type        <= `RAM;
    end else begin // IF
        stage           <= 4'h0;
        cpu_mem_a       <= `ZeroWord;
        cpu_mem_wr      <= `Read;
        if (cachehit == `True) begin
//            $display("cache hit");
            type        <= `INS;
            stage       <= 4'h0;
            res_rdy     <= `True;
            if (tag0[pc[`IndexBus]] == pc[`TagBus]) begin
                ram_data <= ins0[pc[`IndexBus]];
            end else begin
                ram_data <= ins1[pc[`IndexBus]];
            end
        end else begin
//            $display("cache miss %d", pc);
            ram_addr    <= pc;
            stage[3:0]  <= 4'b1011;
            cpu_mem_a   <= pc + 3;
            cpu_mem_wr  <= `Read;
            res_rdy     <= `False;
            type        <= `INS;
        end
    end
end

integer i, j;

always @ (*) begin // Control status
//    $display("lalal %d", j);
//    j = j + 1;
//    $display("ctrl");

    if (rst == `RstEnable) begin
        ram_ok      = `False;
        inst_ok     = `False;
        ram_data_o  = `ZeroWord;
        inst_o      = `ZeroWord;
        j = 0;
    end else if (rdy_in == `False) begin
        ram_ok      = `False;
        inst_ok     = `False;
        ram_data_o  = `ZeroWord;
        inst_o      = `ZeroWord;
    end else if (res_rdy == `True) begin
        if (type == `RAM) begin
            ram_ok      = `True;
            inst_ok     = `False;
            ram_data_o  = ram_data;
            inst_o      = `ZeroWord;
        end else if (type == `INS) begin
            ram_ok      = `False;
            inst_ok     = `True;
            ram_data_o  = `ZeroWord;
            inst_o      = ram_data;
        end
    end else begin 
        ram_ok      <= `False;
        inst_ok     <= `False;
        ram_data_o  <= `ZeroWord;
        inst_o      <= `ZeroWord;
    end
end

always @ (posedge clk or posedge inst_ok) begin // refresh cache 
//    $display("ref %d", j);
//    j = j + 1;
    if (rst == `RstEnable) begin
        for (i = 0; i < `IndexSize; i = i + 1) begin
            tag0[i] <= `CacheNAN;
            tag1[i] <= `CacheNAN;
            ins0[i] <= `ZeroWord;
            ins1[i] <= `ZeroWord;
            lrut[i] <= 1'b0;
        end
    end else if (inst_ok == `True) begin
//        $display("Cache refresh %d %d : %d", pc[`IndexBus], pc[`TagBus], inst_o);
        if (tag0[pc[`IndexBus]] == pc[`TagBus]) begin
            lrut[pc[`TagBus]]   <= 1'b1;
        end else if (tag1[pc[`IndexBus]] == pc[`TagBus]) begin
            lrut[pc[`TagBus]]   <= 1'b0;
        end else if (lrut[pc[`IndexBus]] == 1'b0) begin
            tag0[pc[`IndexBus]] <= pc[`TagBus];
            ins0[pc[`IndexBus]] <= inst_o;
            lrut[pc[`TagBus]]   <= 1'b1;
        end else if (lrut[pc[`IndexBus]] == 1'b1) begin
            tag1[pc[`IndexBus]] <= pc[`TagBus];
            ins1[pc[`IndexBus]] <= inst_o;
            lrut[pc[`TagBus]]   <= 1'b0;
        end
    end
end

endmodule