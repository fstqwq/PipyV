module IF (
    input wire[`InstAddrBus] pc,
    input wire[`InstBus] inst,
    input wire rst,

    input wire pc_done,

    output reg[`InstAddrBus] pc_o,
    output reg[`InstBus] inst_o,
    output reg stall_req_o
);

always @ ( * ) begin
    if(rst) begin
        inst_o = `ZeroWord;
        stall_req_o = 1'b0;
        pc_o = `ZeroWord;
        //inst_o = `ZeroWord;
    end else if(pc_done) begin
        stall_req_o = 1'b0;
        inst_o = inst;
        pc_o = pc;
    end else begin
        stall_req_o = 1'b1;
        inst_o = `ZeroWord;
        pc_o = `ZeroWord;
    end
end

endmodule // if
