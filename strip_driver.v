module strip_driver(
    input rst,
    input clk,

    input mem_rdy,
    output mem_req,
    output[ADDRESS_WIDTH-1:0] mem_addr,
    input[7:0] mem_data,
    output strip_out
);

  parameter INPUT_CLOCK_FREQ_MHZ = 50;
  parameter MAX_LEDS = 3;
  parameter NUM_CHANNELS = 3;

  parameter ADDRESS_WIDTH = 13;
  parameter MAX_CHANNEL_INDEX = (MAX_LEDS * NUM_CHANNELS) - 1;
  parameter BASE_ADDRESS = 0;

  parameter TOTAL_PULSE_TIME_NS = 1400;
  parameter ZERO_PULSE_TIME_NS = 400;
  parameter ONE_PULSE_TIME_NS = 1000;
  parameter RESET_PULSE_TIME_NS = 1000000;

  parameter TOTAL_PULSE_TIME = (TOTAL_PULSE_TIME_NS * INPUT_CLOCK_FREQ_MHZ / 1000) - 1;
  parameter ZERO_PULSE_TIME = (ZERO_PULSE_TIME_NS * INPUT_CLOCK_FREQ_MHZ / 1000) - 1;
  parameter ONE_PULSE_TIME = (ONE_PULSE_TIME_NS * INPUT_CLOCK_FREQ_MHZ / 1000) - 1;
  parameter RESET_PULSE_TIME = (RESET_PULSE_TIME_NS * INPUT_CLOCK_FREQ_MHZ / 1000) - 1;

  reg drive_state;
  parameter DRIVE_DRIVING = 0;
  parameter DRIVE_RESET = 1;

  reg pulse_state;
  parameter PULSE_FIRST_HALF = 0;
  parameter PULSE_SECOND_HALF = 1;

  reg[$clog2(RESET_PULSE_TIME) + 1:0] pulse_counter;
  reg[$clog2(RESET_PULSE_TIME) + 1:0] pulse_counter_match;

  parameter CHANNEL_WIDTH = 8;

  reg[$clog2(MAX_CHANNEL_INDEX) + 1:0] channel_counter;
  reg[$clog2(MAX_CHANNEL_INDEX) + 1:0] mem_addr_reg;
  reg[$clog2(CHANNEL_WIDTH) + 1:0] bit_counter;

  reg current_bit;

  assign mem_addr = mem_addr_reg;
  reg mem_req_reg;
  assign mem_req = mem_req_reg;
  reg[7:0] mem_buffer_reg;

  wire strip_out;
  reg strip_out_reg;
  assign strip_out = strip_out_reg;

  always @(posedge clk) begin
    if (rst) begin
      // Held in reset. Perform reset actions.
      channel_counter <= 0;
      current_bit <= 0;
      drive_state <= DRIVE_RESET;
      strip_out_reg <= 0;
      pulse_counter <= 0;
      pulse_counter_match <= RESET_PULSE_TIME;
      pulse_state <= 0;
      bit_counter <= CHANNEL_WIDTH - 1;
      mem_addr_reg <= BASE_ADDRESS;
      mem_buffer_reg <= 0;
      mem_req_reg <= 1;
    end else begin
      if (mem_rdy & mem_req_reg) begin
        mem_buffer_reg <= mem_data;
        mem_req_reg <= 0;
      end
      if (drive_state == DRIVE_DRIVING) begin
      // Driving the bits to the strip
        if (pulse_counter == pulse_counter_match) begin
          // Counter has matched. This occurs for two reasons:
          if (pulse_state == PULSE_SECOND_HALF) begin
          // 2) End of the bit time has been reached. Reset the counter and
          // load the next bit.
            pulse_counter <= 0;
            if (channel_counter == (MAX_CHANNEL_INDEX + 1)) begin
              // We have finished driving the last channel. Clear the output to
              // start the reset band.
              strip_out_reg <= 0;
              drive_state <= DRIVE_RESET;
              pulse_counter_match <= RESET_PULSE_TIME;
              channel_counter <= 0;
              mem_addr_reg <= BASE_ADDRESS;
              mem_req_reg <= 1;
              bit_counter <= CHANNEL_WIDTH - 1;
            end else begin
              // Another bit still needs to be sent.
              strip_out_reg <= 1;
              pulse_counter_match <= current_bit ? ONE_PULSE_TIME : ZERO_PULSE_TIME;
              if (bit_counter == 0) begin
                channel_counter <= channel_counter + 1;
                if (mem_addr_reg != MAX_CHANNEL_INDEX) begin
                    mem_addr_reg <= mem_addr_reg + 1;
                    mem_req_reg <= 1;
                end
                bit_counter <= CHANNEL_WIDTH - 1;
              end else begin
                bit_counter <= bit_counter - 1;
              end
            end
          end else if (pulse_state == PULSE_FIRST_HALF) begin
          // 1) One or Zero band time has been reached.
            pulse_counter_match <= TOTAL_PULSE_TIME;
            strip_out_reg <= 0;
            current_bit <= mem_buffer_reg[bit_counter];
          end
          pulse_state <= !pulse_state;
        end else begin
          pulse_counter <= pulse_counter + 1;
        end
      end else if (drive_state == DRIVE_RESET) begin
        // Sending the RESET pulse
        // Reset mode; just finished a single strip refresh
        if (pulse_counter == pulse_counter_match) begin
          pulse_counter <= 0;
          pulse_counter_match <= 0;
          drive_state <= DRIVE_DRIVING;
          //strip_out_reg <= 1;

          // Set up the state machine for the first bit of the string.
          current_bit <= mem_buffer_reg[bit_counter];
          //bit_counter <= bit_counter - 1;
          pulse_state <= PULSE_SECOND_HALF;
        end else begin
          pulse_counter <= pulse_counter + 1;
        end
      end
    end
  end

endmodule
