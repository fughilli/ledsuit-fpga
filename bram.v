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
