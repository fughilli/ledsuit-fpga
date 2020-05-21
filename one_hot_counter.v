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

module OneHotCounter(
    input rst,
    input clk,
    input count
);

parameter WIDTH = 5;

reg[WIDTH-1:0] counter;

always @(posedge clk) begin
    if (rst) begin
        counter <= 1;
    end else begin
        if (count) begin
            counter <= {counter[WIDTH-2:0], counter[WIDTH-1]};
        end
    end
end

endmodule
