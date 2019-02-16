module mojo_top (
    input clk,
    input rst_n,
    output [7:0] led,
    output spi_miso,
    input spi_ss,
    input spi_mosi,
    input spi_sck,

    output s_spi_miso,
    input s_spi_ss,
    input s_spi_mosi,
    inout s_spi_clk,

    input avr_tx,
    output reg avr_rx,
    input avr_rx_busy,
    output led_strip_do
  );

  wire rst, rst_unconditioned;

  assign rst_unconditioned = ~rst_n;

  reset_conditioner reset_cond (
    .clk(clk),
    .in(rst_unconditioned),
    .out(rst)
  );

  wire mem_wea;
  reg[12:0] mem_addra;
  wire[7:0] mem_douta;

  wire mem_web;
  reg[12:0] mem_addrb;
  reg[7:0] mem_dinb;
  wire[7:0] mem_doutb;

  parameter MEMORY_STATE_WRITE_ADDRESS = 0;
  parameter MEMORY_STATE_WRITE_DATA = 1;
  reg[2:0] memory_address_position;
  reg[2:0] memory_state;

  blk_mem_gen_v7_3 blk_mem (.clka(clk), .rsta(rst), .wea(mem_wea),
                   .addra(mem_addra), .dina(), .douta(mem_douta),
                   .clkb(clk), .rstb(rst), .web(mem_web),
                   .addrb(mem_addrb), .dinb(mem_dinb), .doutb(mem_doutb));

  // Always write disable port A (port A is used to drive the strips).
  assign mem_wea = 0;
  // Not writing; terminate DINA as 0.
  assign mem_dina = 8'h00;
  // Always write enable port B (port B is driven by the SPI slave).

  wire[7:0] spi_din;
  wire spi_done;
  wire[7:0] spi_dout;

  // Use a register for `mem_web`.
  reg mem_web_reg;
  assign mem_web = mem_web_reg;

  spi_slave spi_out (
    .clk(clk),
    .din(spi_din),
    .done(spi_done),
    .dout(spi_dout),
    .miso(s_spi_miso),
    .mosi(s_spi_mosi),
    .rst(rst),
    .sck(s_spi_clk),
    .ss(s_spi_ss)
  );

  assign spi_din = mem_doutb;

  // Not using the AVR SPI port. Terminate MISO as HiZ.
  assign spi_miso = 1'bz;

  // Slave SPI port slave select is active-low.
  wire spi_selected = ~s_spi_ss;

  // Debug output on the LED array.
  assign led = {mem_addrb[3:0], memory_address_position[1:0], memory_state[1:0]};

  reg write_op_selected;
  reg increment_address;

  // Memory address is provided as two bytes:
  //
  // +---+---+---+---+---+---+---+---+  +---+---+---+---+---+---+---+---+
  // | w |   |   | a | a | a | a | a |  | a | a | a | a | a | a | a | a |
  // +---+---+---+---+---+---+---+---+  +---+---+---+---+---+---+---+---+
  //
  // w = write enable
  // a = 13-bit address
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
      mem_addrb <= 13'h0000;
      mem_dinb <= 8'h00;
      memory_address_position <= 0;
      memory_state <= MEMORY_STATE_WRITE_ADDRESS;
      mem_web_reg <= 0;
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

            mem_web_reg <= 0;
            // Shift in the address component.
            mem_addrb <= {mem_addrb[4:0], spi_dout};
            memory_address_position <= memory_address_position + 1;

            if (memory_address_position == 1) begin
              // Done capturing the address. Advance the state machine.
              memory_state <= MEMORY_STATE_WRITE_DATA;
            end
          end else if (memory_state == MEMORY_STATE_WRITE_DATA) begin
            mem_dinb <= spi_dout;
            mem_web_reg <= write_op_selected;
            // Increment the address on the next cycle, when `spi_done` is
            // cleared.
            increment_address <= 1;
          end
        end else begin
          mem_web_reg <= 0;
          increment_address <= 0;
          if (increment_address) begin
            mem_addrb <= mem_addrb + 1;
          end
        end
      end else begin
        // Slave SPI port is inactive. Reset memory controller state.
        mem_web_reg <= 0;
        increment_address <= 0;
        memory_state <= MEMORY_STATE_WRITE_ADDRESS;
        memory_address_position <= 0;
        write_op_selected <= 0;
      end
    end
  end

  parameter NUM_LEDS = 160;
  parameter TOTAL_PULSE_TIME = 70;
  parameter ZERO_PULSE_TIME = 20;
  parameter ONE_PULSE_TIME = 50;
  parameter RESET_PULSE_TIME = 50000;

  parameter NUM_CHANNELS = 3;
  parameter TOTAL_NUM_CHANNELS = NUM_LEDS * NUM_CHANNELS;

  parameter DRIVE_DRIVING = 0;
  parameter DRIVE_RESET = 1;

  reg drive_state;
  reg[$clog2(RESET_PULSE_TIME)+1:0] pulse_counter;

  parameter CHANNEL_COUNTER_UPPER_BIT = $clog2(TOTAL_NUM_CHANNELS)+1;
  parameter CHANNEL_WIDTH = 8;

  reg[CHANNEL_COUNTER_UPPER_BIT:0] channel_counter;
  reg[CHANNEL_COUNTER_UPPER_BIT:0] channel_counter_q;
  reg[4:0] sub_channel_counter;
  reg[4:0] sub_channel_counter_q;
  reg led_strip_do_reg;

  assign led_strip_do = led_strip_do_reg;

  reg current_bit;
  reg update_current_bit;

  always @(posedge clk) begin
    avr_rx = 1'bz;


    if (rst) begin
      // Held in reset. Perform reset actions.
      channel_counter <= 0;
      channel_counter_q <= 0;
      sub_channel_counter <= 0;
      sub_channel_counter_q <= 0;
      pulse_counter = 0;
      current_bit <= 0;
      update_current_bit <= 0;
      drive_state = DRIVE_RESET;
      mem_addra <= 0;
    end else begin
      if (update_current_bit) begin
        update_current_bit <= 0;
        current_bit <= mem_douta[sub_channel_counter];
        sub_channel_counter <= sub_channel_counter_q;
        channel_counter <= channel_counter_q;
      end
      if (drive_state == DRIVE_DRIVING) begin
        // Driving mode
        if (pulse_counter < (TOTAL_PULSE_TIME - 1)) begin
          pulse_counter = pulse_counter + 1;
          if (current_bit == 0) begin
              led_strip_do_reg = (pulse_counter < ZERO_PULSE_TIME) ? 1'b1 : 1'b0;
          end else begin
              led_strip_do_reg = (pulse_counter < ONE_PULSE_TIME) ? 1'b1 : 1'b0;
          end
        end else begin
          if (sub_channel_counter < (CHANNEL_WIDTH - 1)) begin
            sub_channel_counter_q <= sub_channel_counter + 1;
          end else begin
            sub_channel_counter_q <= 0;
            if (channel_counter < (TOTAL_NUM_CHANNELS - 1)) begin
              channel_counter_q <= channel_counter + 1;
            end else begin
              channel_counter_q <= 0;
              drive_state = DRIVE_RESET;
            end
          end
          mem_addra <= {{(12-CHANNEL_COUNTER_UPPER_BIT){1'b0}}, channel_counter};
          update_current_bit <= 1;
          pulse_counter = 0;
        end
      end else if (drive_state == DRIVE_RESET) begin
        // Reset mode; just finished a single strip refresh
        led_strip_do_reg = 0;
        if (pulse_counter < (RESET_PULSE_TIME - 1)) begin
          pulse_counter = pulse_counter + 1;
        end else begin
          pulse_counter = 0;
          drive_state = DRIVE_DRIVING;
        end
      end
    end
  end

endmodule
