//
// LED Suit FPGA Implementation - Multi-output addressable LED driver HDL
// implementation for Kevin's LED suit controller.
// Copyright (C) 2019-2020 Kevin Balke
//
// This file is part of LED Suit FPGA Implementation.
//
// LED Suit FPGA Implementation is free software: you can redistribute it and/or
// modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// LED Suit FPGA Implementation is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with LED Suit FPGA Implementation.  If not, see
// <http://www.gnu.org/licenses/>.
//

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
    input data_req_2,
    input[ADDRESS_WIDTH-1:0] data_addr_2,
    output[DATA_WIDTH-1:0] data_2,
    output data_rdy_2,
    input data_req_3,
    input[ADDRESS_WIDTH-1:0] data_addr_3,
    output[DATA_WIDTH-1:0] data_3,
    output data_rdy_3,
    input data_req_4,
    input[ADDRESS_WIDTH-1:0] data_addr_4,
    output[DATA_WIDTH-1:0] data_4,
    output data_rdy_4,
    input data_req_5,
    input[ADDRESS_WIDTH-1:0] data_addr_5,
    output[DATA_WIDTH-1:0] data_5,
    output data_rdy_5,
    input data_req_6,
    input[ADDRESS_WIDTH-1:0] data_addr_6,
    output[DATA_WIDTH-1:0] data_6,
    output data_rdy_6,
    input data_req_7,
    input[ADDRESS_WIDTH-1:0] data_addr_7,
    output[DATA_WIDTH-1:0] data_7,
    output data_rdy_7,

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
// ARBITER CHANNEL 2
// Output data latches.
reg[DATA_WIDTH-1:0] data_reg_2;
assign data_2 = data_reg_2;

// Output ready latches.
reg data_rdy_reg_2;
assign data_rdy_2 = data_rdy_reg_2;

// Outstanding request control lines for each data channel.
wire data_req_outstanding_2;
assign data_req_outstanding_2 = (data_req_2 & !data_rdy_reg_2);

// Read completion latch used to implement memory read value pipelining.
reg data_cmpl_read_reg_2;
// ARBITER CHANNEL 3
// Output data latches.
reg[DATA_WIDTH-1:0] data_reg_3;
assign data_3 = data_reg_3;

// Output ready latches.
reg data_rdy_reg_3;
assign data_rdy_3 = data_rdy_reg_3;

// Outstanding request control lines for each data channel.
wire data_req_outstanding_3;
assign data_req_outstanding_3 = (data_req_3 & !data_rdy_reg_3);

// Read completion latch used to implement memory read value pipelining.
reg data_cmpl_read_reg_3;
// ARBITER CHANNEL 4
// Output data latches.
reg[DATA_WIDTH-1:0] data_reg_4;
assign data_4 = data_reg_4;

// Output ready latches.
reg data_rdy_reg_4;
assign data_rdy_4 = data_rdy_reg_4;

// Outstanding request control lines for each data channel.
wire data_req_outstanding_4;
assign data_req_outstanding_4 = (data_req_4 & !data_rdy_reg_4);

// Read completion latch used to implement memory read value pipelining.
reg data_cmpl_read_reg_4;
// ARBITER CHANNEL 5
// Output data latches.
reg[DATA_WIDTH-1:0] data_reg_5;
assign data_5 = data_reg_5;

// Output ready latches.
reg data_rdy_reg_5;
assign data_rdy_5 = data_rdy_reg_5;

// Outstanding request control lines for each data channel.
wire data_req_outstanding_5;
assign data_req_outstanding_5 = (data_req_5 & !data_rdy_reg_5);

// Read completion latch used to implement memory read value pipelining.
reg data_cmpl_read_reg_5;
// ARBITER CHANNEL 6
// Output data latches.
reg[DATA_WIDTH-1:0] data_reg_6;
assign data_6 = data_reg_6;

// Output ready latches.
reg data_rdy_reg_6;
assign data_rdy_6 = data_rdy_reg_6;

// Outstanding request control lines for each data channel.
wire data_req_outstanding_6;
assign data_req_outstanding_6 = (data_req_6 & !data_rdy_reg_6);

// Read completion latch used to implement memory read value pipelining.
reg data_cmpl_read_reg_6;
// ARBITER CHANNEL 7
// Output data latches.
reg[DATA_WIDTH-1:0] data_reg_7;
assign data_7 = data_reg_7;

// Output ready latches.
reg data_rdy_reg_7;
assign data_rdy_7 = data_rdy_reg_7;

// Outstanding request control lines for each data channel.
wire data_req_outstanding_7;
assign data_req_outstanding_7 = (data_req_7 & !data_rdy_reg_7);

// Read completion latch used to implement memory read value pipelining.
reg data_cmpl_read_reg_7;

// Memory address is determined combinatorially, so that we can grab the value
// from the memory synchronously to the request control line.
assign mem_data_addr = (
    (data_req_outstanding_0 ? data_addr_0 :
    (data_req_outstanding_1 ? data_addr_1 :
    (data_req_outstanding_2 ? data_addr_2 :
    (data_req_outstanding_3 ? data_addr_3 :
    (data_req_outstanding_4 ? data_addr_4 :
    (data_req_outstanding_5 ? data_addr_5 :
    (data_req_outstanding_6 ? data_addr_6 :
    (data_req_outstanding_7 ? data_addr_7 :
    0
    )
    )
    )
    )
    )
    )
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
        data_rdy_reg_2 <= 0;
        data_reg_2 <= 0;
        data_cmpl_read_reg_2 <= 0;
        data_rdy_reg_3 <= 0;
        data_reg_3 <= 0;
        data_cmpl_read_reg_3 <= 0;
        data_rdy_reg_4 <= 0;
        data_reg_4 <= 0;
        data_cmpl_read_reg_4 <= 0;
        data_rdy_reg_5 <= 0;
        data_reg_5 <= 0;
        data_cmpl_read_reg_5 <= 0;
        data_rdy_reg_6 <= 0;
        data_reg_6 <= 0;
        data_cmpl_read_reg_6 <= 0;
        data_rdy_reg_7 <= 0;
        data_reg_7 <= 0;
        data_cmpl_read_reg_7 <= 0;
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
        if (!data_req_2) begin
            data_rdy_reg_2 <= 0;
            data_cmpl_read_reg_2 <= 0;
        end
        if (!data_req_3) begin
            data_rdy_reg_3 <= 0;
            data_cmpl_read_reg_3 <= 0;
        end
        if (!data_req_4) begin
            data_rdy_reg_4 <= 0;
            data_cmpl_read_reg_4 <= 0;
        end
        if (!data_req_5) begin
            data_rdy_reg_5 <= 0;
            data_cmpl_read_reg_5 <= 0;
        end
        if (!data_req_6) begin
            data_rdy_reg_6 <= 0;
            data_cmpl_read_reg_6 <= 0;
        end
        if (!data_req_7) begin
            data_rdy_reg_7 <= 0;
            data_cmpl_read_reg_7 <= 0;
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
            else
        if (data_req_outstanding_2) begin
            if (data_cmpl_read_reg_2) begin
                data_reg_2 <= mem_data;
                data_rdy_reg_2 <= 1;
            end else begin
                data_cmpl_read_reg_2 <= 1;
            end
        end
            else
        if (data_req_outstanding_3) begin
            if (data_cmpl_read_reg_3) begin
                data_reg_3 <= mem_data;
                data_rdy_reg_3 <= 1;
            end else begin
                data_cmpl_read_reg_3 <= 1;
            end
        end
            else
        if (data_req_outstanding_4) begin
            if (data_cmpl_read_reg_4) begin
                data_reg_4 <= mem_data;
                data_rdy_reg_4 <= 1;
            end else begin
                data_cmpl_read_reg_4 <= 1;
            end
        end
            else
        if (data_req_outstanding_5) begin
            if (data_cmpl_read_reg_5) begin
                data_reg_5 <= mem_data;
                data_rdy_reg_5 <= 1;
            end else begin
                data_cmpl_read_reg_5 <= 1;
            end
        end
            else
        if (data_req_outstanding_6) begin
            if (data_cmpl_read_reg_6) begin
                data_reg_6 <= mem_data;
                data_rdy_reg_6 <= 1;
            end else begin
                data_cmpl_read_reg_6 <= 1;
            end
        end
            else
        if (data_req_outstanding_7) begin
            if (data_cmpl_read_reg_7) begin
                data_reg_7 <= mem_data;
                data_rdy_reg_7 <= 1;
            end else begin
                data_cmpl_read_reg_7 <= 1;
            end
        end
    end
end

endmodule