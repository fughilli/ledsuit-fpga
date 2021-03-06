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

{% set num_channels = 8 %}
{% set indices = range(num_channels) %}
module bus_arbiter(
    input clk,
    input rst,

    {% for index in indices %}
    input data_req_{{index}},
    input[ADDRESS_WIDTH-1:0] data_addr_{{index}},
    output[DATA_WIDTH-1:0] data_{{index}},
    output data_rdy_{{index}},
    {% endfor %}

    output[ADDRESS_WIDTH-1:0] mem_data_addr,
    input[DATA_WIDTH-1:0] mem_data
);

parameter ADDRESS_WIDTH = 8;
parameter DATA_WIDTH = 8;

{% for index in indices %}
// ARBITER CHANNEL {{index}}
// Output data latches.
reg[DATA_WIDTH-1:0] data_reg_{{index}};
assign data_{{index}} = data_reg_{{index}};

// Output ready latches.
reg data_rdy_reg_{{index}};
assign data_rdy_{{index}} = data_rdy_reg_{{index}};

// Outstanding request control lines for each data channel.
wire data_req_outstanding_{{index}};
assign data_req_outstanding_{{index}} = (data_req_{{index}} & !data_rdy_reg_{{index}});

// Read completion latch used to implement memory read value pipelining.
reg data_cmpl_read_reg_{{index}};
{% endfor %}

// Memory address is determined combinatorially, so that we can grab the value
// from the memory synchronously to the request control line.
assign mem_data_addr = (
    {% for index in indices %}
    (data_req_outstanding_{{index}} ? data_addr_{{index}} :
    {% endfor %}
    0
    {% for index in indices %}
    )
    {% endfor %}
);


always @(posedge clk) begin
    if (rst) begin
        {% for index in indices %}
        data_rdy_reg_{{index}} <= 0;
        data_reg_{{index}} <= 0;
        data_cmpl_read_reg_{{index}} <= 0;
        {% endfor %}
    end else begin
        // If request control line goes low, reset the ready latch.
        {% for index in indices %}
        if (!data_req_{{index}}) begin
            data_rdy_reg_{{index}} <= 0;
            data_cmpl_read_reg_{{index}} <= 0;
        end
        {% endfor %}

        // Priority from 0 -> N: Read memory cell and latch to output.
        {% for index in indices %}
        if (data_req_outstanding_{{index}}) begin
            if (data_cmpl_read_reg_{{index}}) begin
                data_reg_{{index}} <= mem_data;
                data_rdy_reg_{{index}} <= 1;
            end else begin
                data_cmpl_read_reg_{{index}} <= 1;
            end
        end
            {% if index != indices[-1] %}
            else
            {% endif %}
        {% endfor %}
    end
end

endmodule
