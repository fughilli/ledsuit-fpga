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
    output avr_rx,
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
  wire[12:0] mem_addra;
  wire[7:0] mem_douta;

  wire mem_web;
  wire[12:0] mem_addrb;
  wire[7:0] mem_dinb;
  wire[7:0] mem_doutb;

  // Not using the AVR SPI port. Terminate MISO as HiZ.
  assign spi_miso = 1'bz;

  blk_mem_gen_v7_3 blk_mem (.clka(clk), .rsta(rst), .wea(mem_wea),
                   .addra(mem_addra), .dina(mem_dina), .douta(mem_douta),
                   .clkb(clk), .rstb(rst), .web(mem_web),
                   .addrb(mem_addrb), .dinb(mem_dinb), .doutb(mem_doutb));

  wire[7:0] spi_din;
  wire spi_done;
  wire[7:0] spi_dout;

  // Slave SPI port slave select is active-low.
  wire spi_selected;

  spi_slave spi_out (
    .clk(clk),
    .din(spi_din),
    .done(spi_done),
    .dout(spi_dout),
    .miso(s_spi_miso),
    .mosi(s_spi_mosi),
    .rst(rst),
    .sck(s_spi_clk),
    .ss(s_spi_ss),
    .selected(spi_selected)
  );

  // Always write disable port A (port A is used to drive the strips).
  assign mem_wea = 0;
  // Not writing; terminate DINA as 0.
  assign mem_dina = 8'h00;

  assign avr_rx = 1'bz;

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

  wire strip_driver_1_mem_en;
  wire strip_driver_2_mem_en;

  LedStripDriver #(.BASE_ADDRESS(0), .MEMORY_READ_ENABLE_DELAY(1)) strip_driver_1 (
      .clk(clk),
      .rst(rst),

      .mem_addr(mem_addra),
      .mem_data(mem_douta),
      .mem_read_enable(strip_driver_1_mem_en),

      .strip_out(led_strip_do)
  );

endmodule
