module bram(
    input clk,

    input wen,
    input[DATA_WIDTH - 1:0] wdata,
    input[ADDRESS_WIDTH - 1:0] waddr,
    
    input ren,
    output[DATA_WIDTH - 1:0] rdata,
    input[ADDRESS_WIDTH - 1:0] raddr
);

parameter MEMORY_SIZE= 128;

parameter DATA_WIDTH = 8;
parameter ADDRESS_WIDTH = $clog2(MEMORY_SIZE);

reg[DATA_WIDTH - 1:0] memory[0:MEMORY_SIZE - 1];

reg[DATA_WIDTH - 1:0] rdata_reg;
assign rdata = rdata_reg;

always @(posedge clk) begin
    if (wen) begin
        memory[waddr] <= wdata;
    end
    if (ren) begin
        rdata_reg <= memory[raddr];
    end
end
endmodule
