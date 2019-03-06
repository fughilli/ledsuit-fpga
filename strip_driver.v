module LedStripDriver(
    input rst,
    input clk,

    output reg[ADDRESS_WIDTH-1:0] mem_addr,
    input[7:0] mem_data,
    output reg mem_read_enable,

    output strip_out
);

  parameter MAX_LEDS = 200;
  parameter NUM_CHANNELS = 3;

  parameter ADDRESS_WIDTH = 13;
  parameter MAX_CHANNEL_INDEX = MAX_LEDS * NUM_CHANNELS;
  parameter MAX_CHANNEL_INDEX_BITS = $clog2(MAX_CHANNEL_INDEX) + 1;
  parameter BASE_ADDRESS = 0;

  parameter MEMORY_READ_ENABLE_DELAY = 3;

  parameter TOTAL_PULSE_TIME = 70;
  parameter ZERO_PULSE_TIME = 20;
  parameter ONE_PULSE_TIME = 50;
  parameter RESET_PULSE_TIME = 50000;

  parameter DRIVE_DRIVING = 0;
  parameter DRIVE_RESET = 1;

  reg drive_state;
  reg[$clog2(RESET_PULSE_TIME)+1:0] pulse_counter;

  parameter CHANNEL_WIDTH = 8;

  reg[MAX_CHANNEL_INDEX_BITS-1:0] channel_counter;
  reg[4:0] sub_channel_counter;
  reg led_strip_do_reg;

  assign strip_out = led_strip_do_reg;

  reg current_bit;
  reg update_current_bit;

  always @(posedge clk) begin
    if (rst) begin
      // Held in reset. Perform reset actions.
      sub_channel_counter <= 0;
      pulse_counter <= 0;
      current_bit <= 0;
      drive_state <= DRIVE_RESET;
      mem_addr <= BASE_ADDRESS;
      channel_counter <= MAX_CHANNEL_INDEX - 1;
    end else begin
      if (drive_state == DRIVE_DRIVING) begin
        // Driving mode
        if (pulse_counter < (TOTAL_PULSE_TIME - 1)) begin
          if (pulse_counter == MEMORY_READ_ENABLE_DELAY) begin
            mem_read_enable <= 1;
          end
          if (pulse_counter == (MEMORY_READ_ENABLE_DELAY + 1)) begin
            mem_read_enable <= 0;
            current_bit <= mem_data[sub_channel_counter];
          end
          pulse_counter <= pulse_counter + 1;
          if (current_bit == 0) begin
              led_strip_do_reg <= (pulse_counter < ZERO_PULSE_TIME) ? 1'b1 : 1'b0;
          end else begin
              led_strip_do_reg <= (pulse_counter < ONE_PULSE_TIME) ? 1'b1 : 1'b0;
          end
        end else begin
          if (sub_channel_counter != 0) begin
            sub_channel_counter <= sub_channel_counter - 1;
          end else begin
            sub_channel_counter <= CHANNEL_WIDTH - 1;
            if (channel_counter != 0) begin
              mem_addr <= mem_addr + 1;
              channel_counter <= channel_counter - 1;
            end else begin
              channel_counter <= MAX_CHANNEL_INDEX - 1;
              mem_addr <= BASE_ADDRESS;
              drive_state <= DRIVE_RESET;
            end
          end
          pulse_counter <= 0;
        end
      end else if (drive_state == DRIVE_RESET) begin
        // Reset mode; just finished a single strip refresh
        led_strip_do_reg <= 0;
        if (pulse_counter < (RESET_PULSE_TIME - 1)) begin
          pulse_counter <= pulse_counter + 1;
        end else begin
          pulse_counter <= 0;
          drive_state <= DRIVE_DRIVING;
        end
      end
    end
  end

endmodule
