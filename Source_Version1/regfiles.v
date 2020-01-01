`include "defines.v"

module regfile (
    input wire clk,
    input wire rst,

    input wire                  w_req,
    input wire[`RegAddrBus]     w_addr,
    input wire[`RegBus]         w_data,

    input wire                  r1_req,
    input wire[`RegAddrBus]     r1_addr,
    output reg[`RegBus]         r1_data,

    input wire                  r2_req,
    input wire[`RegAddrBus]     r2_addr,
    output reg[`RegBus]         r2_data
);

reg[`RegBus] regs[0:`RegNum-1];

integer i;

always @ (posedge clk) begin
    if (rst == `RstEnable) begin
//        $display("??");
        for (i = 0; i < `RegNum; i = i + 1)
            regs[i] = `ZeroWord;
    end else begin
        if ((w_req == `True) && (w_addr != `RegNumLog2'h0)) begin	
        //	$display("rw %h %h", w_addr, w_data);
    /*        for (i = 0; i < `RegNum; i = i + 1) begin
                $write("(%2h,%h)",i,regs[i]);
            end
            $display("");*/
            regs[w_addr] <= w_data;
        end
        
    end
end

always @ (*) begin
    if (rst == `RstEnable) begin
        r1_data <= `ZeroWord;
    end else if (r1_addr == `RegNumLog2'h0) begin
        r1_data <= `ZeroWord;
    end else if ((r1_addr == w_addr) && (w_req == `True) && (r1_req == `True)) begin
        r1_data <= w_data; // forwarding
    end else if (r1_req == `True) begin
        r1_data <= regs[r1_addr];
    end else begin
        r1_data <= `ZeroWord;
    end
end

always @ (*) begin
    if (rst == `RstEnable) begin
        r2_data <= `ZeroWord;
    end else if (r2_addr == `RegNumLog2'h0) begin
        r2_data <= `ZeroWord;
    end else if ((r2_addr == w_addr) && (w_req == `True) && (r2_req == `True)) begin
        r2_data <= w_data; // forwarding
    end else if (r2_req == `True) begin
        r2_data <= regs[r2_addr];
    end else begin
        r2_data <= `ZeroWord;
    end
end

endmodule
