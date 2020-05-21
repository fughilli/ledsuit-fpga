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

module reset_conditioner (
    input clk,  // clock
    input in,   // async reset
    output reg out  // snyc reset
  );

  parameter STAGES = 4;
  //dff stage[STAGES] (.clk(clk), .rst(in), #INIT(STAGESx{1}));

  reg [STAGES - 1:0] stage;

  always @(posedge clk) begin
    if(in) begin
      stage <= {STAGES{1'b1}};
      out <= 1;
    end else begin
      stage <= {stage[STAGES-2:0],1'b0};
      out <= stage[STAGES-1];
    end
  end

endmodule
