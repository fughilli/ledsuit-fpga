module mojo_top (
    input clk,
    input rst_n,
    output [7:0] led,
    output reg spi_miso,
    input spi_ss,
    input spi_mosi,
    input spi_sck,
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

  parameter NUM_LEDS = 160;
  parameter TOTAL_PULSE_TIME = 70;
  parameter ZERO_PULSE_TIME = 20;
  parameter ONE_PULSE_TIME = 50;
  parameter RESET_PULSE_TIME = 50000;

  parameter NUM_BITS = NUM_LEDS * 24;

  parameter DRIVE_DRIVING = 0;
  parameter DRIVE_RESET = 1;

  reg drive_state;
  reg[$clog2(RESET_PULSE_TIME)+1:0] pulse_counter;

  parameter LED_COUNTER_UPPER_BIT = $clog2(NUM_BITS)+1;

  reg[LED_COUNTER_UPPER_BIT:0] led_counter;
  reg[$clog2(NUM_BITS)+1:0] zipper_register;
  reg[23:0] color;
  reg[32:0] counter;
  reg led_strip_do_reg;

  assign led_strip_do = led_strip_do_reg;

  reg current_bit;

  assign led[7:0] = 8'bzzzzzzzz;

  always @(posedge clk) begin
    spi_miso = 1'bz;
    avr_rx = 1'bz;


    if (rst) begin
      // Held in reset. Perform reset actions.
      counter = 0;
      led_counter = 0;
      pulse_counter = 0;
      color = 24'h000000;
      current_bit = 0;
      drive_state = DRIVE_RESET;
      zipper_register = 0;
    end else begin
      if (drive_state == DRIVE_DRIVING) begin
        if (pulse_counter < (TOTAL_PULSE_TIME - 1)) begin
          pulse_counter = pulse_counter + 1;
          if (current_bit == 0) begin
              led_strip_do_reg = (pulse_counter < ZERO_PULSE_TIME) ? 1'b1 : 1'b0;
          end else begin
              led_strip_do_reg = (pulse_counter < ONE_PULSE_TIME) ? 1'b1 : 1'b0;
          end
        end else begin
          if (led_counter < (NUM_BITS - 1)) begin
            led_counter = led_counter + 1;
          end else begin
            led_counter = 0;
            drive_state = DRIVE_RESET;
          end
          current_bit = (zipper_register == led_counter);
          pulse_counter = 0;
        end
      end else if (drive_state == DRIVE_RESET) begin
        led_strip_do_reg = 0;
        if (pulse_counter < (RESET_PULSE_TIME - 1)) begin
          pulse_counter = pulse_counter + 1;
        end else begin
          pulse_counter = 0;
          drive_state = DRIVE_DRIVING;
          if (zipper_register < (NUM_BITS - 1)) begin
            zipper_register = zipper_register + 8;
          end else begin
            zipper_register = 0;
          end
        end
      end
    end
  end

endmodule
