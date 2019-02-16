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

  assign led = 8'h00;

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
  wire[12:0] mem_addrb;
  wire[7:0] mem_dinb;
  wire[7:0] mem_doutb;

  // Not using the AVR SPI port. Terminate MISO as HiZ.
  assign spi_miso = 1'bz;

  blk_mem_gen_v7_3 blk_mem (.clka(clk), .rsta(rst), .wea(mem_wea),
                   .addra(mem_addra), .dina(), .douta(mem_douta),
                   .clkb(clk), .rstb(rst), .web(mem_web),
                   .addrb(mem_addrb), .dinb(mem_dinb), .doutb(mem_doutb));

  wire[7:0] spi_din;
  wire spi_done;
  wire[7:0] spi_dout;

  // Slave SPI port slave select is active-low.
  wire spi_selected = ~s_spi_ss;

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

  // Always write disable port A (port A is used to drive the strips).
  assign mem_wea = 0;
  // Not writing; terminate DINA as 0.
  assign mem_dina = 8'h00;

  spi_memory #(.ADDRESS_WIDTH(13)) memory (
    .clk(clk),
    .rst(rst),

    // Spi connections
    .spi_din(spi_din),
    .spi_dout(spi_dout),
    .spi_done(spi_done),
    .spi_selected(spi_selected),

    // BRAM port B
    .mem_we(mem_web),
    .mem_din(mem_dinb),
    .mem_dout(mem_doutb),
    .mem_addr(mem_addrb)
  );

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
