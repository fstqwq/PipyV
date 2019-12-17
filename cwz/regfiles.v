`include "defines.vh"

module regfile (
    input wire clk,
    input wire rst,

    input wire we,
    input wire[`RegAddrBus] waddr,
    input wire[`RegBus] wdata,

    input wire re1,
    input wire[`RegAddrBus] raddr1,
    output reg[`RegBus] rdata1,

    input wire re2,
    input wire[`RegAddrBus] raddr2,
    output reg[`RegBus] rdata2
);

reg[`RegBus] regs[`RegNum - 1:0];

integer i;

always @ ( posedge clk ) begin
    if(rst  == `RstDisable) begin
        if((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin
			$display("rw %h %h", waddr, wdata);
/*            for (i = 0; i < `RegNum; i = i + 1) begin
				$write("(%2h,%h)",i,regs[i]);
			end
			$display("");*/
			regs[waddr] <= wdata;
        end
    end else begin
        //regs[0] <= 1'b0;
        for(i = 0; i < `RegNum; i = i + 1)
            regs[i] = 1'b0;
    end
end

always @ ( * ) begin
    if (rst == `RstEnable ) begin
        rdata1 = `ZeroWord;
    end else if ((raddr1 == waddr) && (we == `WriteEnable) && (re1 == `ReadEnable)) begin
        rdata1 = wdata;
    end else if (re1 == `ReadEnable) begin
        rdata1 = regs[raddr1];
    end else begin
        rdata1 = `ZeroWord;
    end
end

always @ ( * ) begin
    if (rst == `RstEnable ) begin
        rdata2 = `ZeroWord;
    end else if ((raddr2 == waddr) && (we == `WriteEnable) && (re2 == `ReadEnable)) begin
		rdata2 = wdata;
    end else if (re2 == `ReadEnable) begin
        rdata2 = regs[raddr2];
    end else begin
        rdata2 = `ZeroWord;
    end
end


endmodule // regfile
