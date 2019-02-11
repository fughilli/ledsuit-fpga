module mojo_top (
    input clk,
    input rst_n,
    output [7:0] led,
    output spi_miso,
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

  reg mem_clka;
  wire mem_wea;
  reg[12:0] mem_addra;
  wire[7:0] mem_dina;
  //wire[7:0] mem_douta;

  reg mem_clkb;
  wire mem_web;
  reg[12:0] mem_addrb;
  reg[7:0] mem_dinb;
  wire[7:0] mem_doutb;

  parameter MEMORY_STATE_WRITE_ADDRESS = 0;
  parameter MEMORY_STATE_WRITE_DATA = 1;
  reg[2:0] memory_address_position;
  reg[2:0] memory_state;

  blk_mem_gen_v7_3(.clka(mem_clk_a), .rsta(rst), .wea(mem_wea),
                   .addra(mem_addra), .dina(mem_dina), .douta(),
                   .clkb(mem_clkb), .rstb(rst), .web(mem_web),
                   .addrb(mem_addrb), .dinb(mem_dinb), .doutb(mem_doutb));

  // Always write disable port A (port A is used to drive the strips).
  assign mem_wea = 0;
  // Not writing; terminate DINA as 0.
  assign mem_dina = 8'h00;
  // Always write enable port B (port B is driven by the SPI slave).
  assign mem_web = 1;

  reg[7:0] spi_din;
  wire spi_done;
  wire[7:0] spi_dout;

  spi_slave spi_out (
    .clk(clk),
    .din(spi_din),
    .done(spi_done),
    .dout(spi_dout),
    .miso(spi_miso),
    .mosi(spi_mosi),
    .rst(rst),
    .sck(spi_clk),
    .ss(spi_ss)
  );

  wire spi_selected = ~spi_ss;

  always @(posedge clk) begin
    if (rst) begin
      mem_clka <= 0;
      mem_addra <= 13'h0000;
      mem_clkb <= 0;
      mem_addrb <= 13'h0000;
      mem_dinb <= 8'h00;
      memory_address_position <= 0;
      memory_state = MEMORY_STATE_WRITE_ADDRESS;
    end else begin
      if (spi_selected) begin
        if (memory_state == MEMORY_STATE_WRITE_ADDRESS) begin
          if (spi_done) begin
            mem_addrb <= {mem_addrb[4:0], spi_dout};
            memory_address_position <= memory_address_position + 1;

            if (memory_address_position == 1) begin
              memory_state = MEMORY_STATE_WRITE_DATA;
            end
          end
        end else if (memory_state == MEMORY_STATE_WRITE_DATA) begin
          spi_din <= mem_doutb;
          mem_dinb <= spi_dout;
          mem_addrb <= mem_addrb + 1;
          mem_clkb <= spi_done;
        end
      end else begin
        mem_clkb <= 0;
        memory_state = MEMORY_STATE_WRITE_ADDRESS;
      end
    end
  end

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
