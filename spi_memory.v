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

module spi_memory(
    input clk,
    input rst,
    // Data read in from the SPI master
    input[7:0] spi_dout,
    // Data to be transmitted to the SPI master
    output[7:0] spi_din,
    input spi_done,
    input spi_selected,

    // Write enable on BRAM port
    output mem_we,
    // Data in on BRAM port
    output reg[7:0] mem_din,
        // Data out on BRAM port
    input[7:0] mem_dout,
    output reg[ADDRESS_WIDTH - 1:0] mem_addr
);
  parameter ADDRESS_WIDTH = 13;
  parameter MEMORY_STATE_WRITE_ADDRESS = 0;
  parameter MEMORY_STATE_WRITE_DATA = 1;
  reg[2:0] memory_address_position;
  reg[2:0] memory_state;



  // Use a register for `mem_we`.
  reg mem_we_reg;
  assign mem_we = mem_we_reg;

  // SPI transmits what's on the BRAM port B output.
  assign spi_din = mem_dout;

  reg write_op_selected;
  reg increment_address;

  wire[ADDRESS_WIDTH-1:0] shifted_mem_addr;
  assign shifted_mem_addr = {mem_addr[6:0], spi_dout};

  // Memory address is provided as two bytes:
  //
  // +---+---+---+---+---+---+---+---+  +---+---+---+---+---+---+---+---+
  // | w | a | a | a | a | a | a | a |  | a | a | a | a | a | a | a | a |
  // +---+---+---+---+---+---+---+---+  +---+---+---+---+---+---+---+---+
  //
  // w = write enable
  // a = up to 15-bit address
  //
  // When writing, perform SPI transaction as follows:
  //
  // CS ENABLE
  // write: address upper byte
  // write: address lower byte
  // write: data value 0
  // write: data value 1
  // ...
  // write: data value N
  // CS DISABLE
  //
  // When reading, perform SPI transaction as follows:
  //
  // CS ENABLE
  // write: address upper byte
  // write: address lower byte
  // write: dummy byte (value ignored)
  // read: -> data value 0
  // read: -> data value 1
  // ...
  // read: -> data value N
  // CS DISABLE
  always @(posedge clk) begin
    if (rst) begin
      // Held in reset.
      mem_addr <= 0;
      mem_din <= 8'h00;
      memory_address_position <= 0;
      memory_state <= MEMORY_STATE_WRITE_ADDRESS;
      mem_we_reg <= 0;
      write_op_selected <= 0;
      increment_address <= 0;
    end else begin
      if (spi_selected) begin
        if (spi_done) begin
          if (memory_state == MEMORY_STATE_WRITE_ADDRESS) begin
            // We are receiving the address.
            if (memory_address_position == 0) begin
              // The first byte contains the write enable bit in the MSB.
              write_op_selected <= spi_dout[7];
            end

            mem_we_reg <= 0;
            // Shift in the address component.
            mem_addr <= shifted_mem_addr[ADDRESS_WIDTH - 1 : 0];
            memory_address_position <= memory_address_position + 1;

            if (memory_address_position == 1) begin
              // Done capturing the address. Advance the state machine.
              memory_state <= MEMORY_STATE_WRITE_DATA;
            end
          end else if (memory_state == MEMORY_STATE_WRITE_DATA) begin
            mem_din <= spi_dout;
            mem_we_reg <= write_op_selected;
            // Increment the address on the next cycle, when `spi_done` is
            // cleared.
            increment_address <= 1;
          end
        end else begin
          mem_we_reg <= 0;
          increment_address <= 0;
          if (increment_address) begin
            mem_addr <= mem_addr + 1;
          end
        end
      end else begin
        // Slave SPI port is inactive. Reset memory controller state.
        mem_we_reg <= 0;
        increment_address <= 0;
        memory_state <= MEMORY_STATE_WRITE_ADDRESS;
        memory_address_position <= 0;
        write_op_selected <= 0;
      end
    end
  end

endmodule
