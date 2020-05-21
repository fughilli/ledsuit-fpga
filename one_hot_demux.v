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

// One-hot demultiplexer. `select` is a one-hot encoded register that connects
// the n'th input to `output` when the n'th bit is hot.

module OneHotDemux(
    input[SELECT_WIDTH-1:0] select,
    input[DATA_WIDTH-1:0] demux_input_0,
    input[DATA_WIDTH-1:0] demux_input_1,
    input[DATA_WIDTH-1:0] demux_input_2,
    input[DATA_WIDTH-1:0] demux_input_3,
    input[DATA_WIDTH-1:0] demux_input_4,
    input[DATA_WIDTH-1:0] demux_input_5,
    input[DATA_WIDTH-1:0] demux_input_6,
    input[DATA_WIDTH-1:0] demux_input_7,
    output[DATA_WIDTH-1:0] demux_output
);

parameter SELECT_WIDTH=8;
parameter DATA_WIDTH=8;

assign demux_output = ((((8'b1) == (select))) ? (demux_input_0) : (((((8'b10) == (select))) ? (demux_input_1) : (((((8'b100) == (select))) ? (demux_input_2) : (((((8'b1000) == (select))) ? (demux_input_3) : (((((8'b10000) == (select))) ? (demux_input_4) : (((((8'b100000) == (select))) ? (demux_input_5) : (((((8'b1000000) == (select))) ? (demux_input_6) : (demux_input_7))))))))))))));

endmodule
