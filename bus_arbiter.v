module bus_arbiter(
    input clk,
    input rst,

    input data_req_0,
    input[ADDRESS_WIDTH-1:0] data_addr_0,
    output[DATA_WIDTH-1:0] data_0,
    output data_rdy_0,
    input data_req_1,
    input[ADDRESS_WIDTH-1:0] data_addr_1,
    output[DATA_WIDTH-1:0] data_1,
    output data_rdy_1,

    output[ADDRESS_WIDTH-1:0] mem_data_addr,
    input[DATA_WIDTH-1:0] mem_data
);

parameter ADDRESS_WIDTH = 8;
parameter DATA_WIDTH = 8;

// ARBITER CHANNEL 0
// Output data latches.
reg[DATA_WIDTH-1:0] data_reg_0;
assign data_0 = data_reg_0;

// Output ready latches.
reg data_rdy_reg_0;
assign data_rdy_0 = data_rdy_reg_0;

// Outstanding request control lines for each data channel.
wire data_req_outstanding_0;
assign data_req_outstanding_0 = (data_req_0 & !data_rdy_reg_0);

// Read completion latch used to implement memory read value pipelining.
reg data_cmpl_read_reg_0;
// ARBITER CHANNEL 1
// Output data latches.
reg[DATA_WIDTH-1:0] data_reg_1;
assign data_1 = data_reg_1;

// Output ready latches.
reg data_rdy_reg_1;
assign data_rdy_1 = data_rdy_reg_1;

// Outstanding request control lines for each data channel.
wire data_req_outstanding_1;
assign data_req_outstanding_1 = (data_req_1 & !data_rdy_reg_1);

// Read completion latch used to implement memory read value pipelining.
reg data_cmpl_read_reg_1;

// Memory address is determined combinatorially, so that we can grab the value
// from the memory synchronously to the request control line.
assign mem_data_addr = (
    (data_req_outstanding_0 ? data_addr_0 :
    (data_req_outstanding_1 ? data_addr_1 :
    0
    )
    )
);


always @(posedge clk) begin
    if (rst) begin
        data_rdy_reg_0 <= 0;
        data_reg_0 <= 0;
        data_cmpl_read_reg_0 <= 0;
        data_rdy_reg_1 <= 0;
        data_reg_1 <= 0;
        data_cmpl_read_reg_1 <= 0;
    end else begin
        // If request control line goes low, reset the ready latch.
        if (!data_req_0) begin
            data_rdy_reg_0 <= 0;
            data_cmpl_read_reg_0 <= 0;
        end
        if (!data_req_1) begin
            data_rdy_reg_1 <= 0;
            data_cmpl_read_reg_1 <= 0;
        end

        // Priority from 0 -> N: Read memory cell and latch to output.
        if (data_req_outstanding_0) begin
            if (data_cmpl_read_reg_0) begin
                data_reg_0 <= mem_data;
                data_rdy_reg_0 <= 1;
            end else begin
                data_cmpl_read_reg_0 <= 1;
            end
        end
            else
        if (data_req_outstanding_1) begin
            if (data_cmpl_read_reg_1) begin
                data_reg_1 <= mem_data;
                data_rdy_reg_1 <= 1;
            end else begin
                data_cmpl_read_reg_1 <= 1;
            end
        end
    end
end

endmodule