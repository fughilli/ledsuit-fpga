module ice40_top (
    input CLK,
    output PIN_1,
    input PIN_2,
    input PIN_3,
    input PIN_4,
    output USBPU
);

// Top-level constants
parameter NUM_LEDS = 72;
parameter NUM_CHANNELS = NUM_LEDS * 3;
parameter ADDRESS_WIDTH = $clog2(NUM_LEDS) + 1;

wire clk_50mhz;
wire clk_16mhz;

assign clk_16mhz = CLK;

// PLL configuration
SB_PLL40_CORE pll_instance (
  .REFERENCECLK(clk_16mhz),
  .PLLOUTCORE(clk_50mhz),
  .RESETB(1),
  .BYPASS(0)
);

defparam pll_instance.DIVR = 0;
defparam pll_instance.DIVF = 49;
defparam pll_instance.DIVQ = 4;
defparam pll_instance.FILTER_RANGE = 3'b001;
defparam pll_instance.FEEDBACK_PATH = "SIMPLE";
defparam pll_instance.DELAY_ADJUSTMENT_MODE_FEEDBACK = "FIXED";
defparam pll_instance.FDA_FEEDBACK = 4'b0000;
defparam pll_instance.DELAY_ADJUSTMENT_MODE_RELATIVE = "FIXED";
defparam pll_instance.FDA_RELATIVE = 4'b0000;
defparam pll_instance.SHIFTREG_DIV_MODE = 2'b00;
defparam pll_instance.PLLOUT_SELECT = "GENCLK";
defparam pll_instance.ENABLE_ICEGATE = 1'b0;

// Disable USB
assign USBPU = 1'b0;

// Reset generation
reg [5:0] reset_cnt = 0;
wire resetn = &reset_cnt;
always @(posedge clk_16mhz) begin
    reset_cnt <= reset_cnt + !resetn;
end
wire rst;
assign rst = !resetn;

// Memory
wire[ADDRESS_WIDTH - 1:0] mem_addr_strip;
reg[7:0] mem[0:NUM_CHANNELS - 1];
wire[7:0] mem_dout;
assign mem_dout = mem[mem_addr_strip];

wire mem_we;
wire[7:0] mem_din;
wire[12:0] mem_addr;

always @(posedge mem_we) begin
    mem[mem_addr[7:0]] <= mem_din;
end

// SPI interface
wire[7:0] spi_dout;
wire[7:0] spi_din;
wire spi_done, spi_selected;

spi_slave spi_out (
    .clk(clk_50mhz),
    .rst(rst),

    .miso(),
    .mosi(PIN_4),
    .sck(PIN_3),
    .ss(PIN_2),

    .din(spi_din),
    .dout(spi_dout),

    .done(spi_done),
    .selected(spi_selected)
);

// SPI memory controller
spi_memory #(.ADDRESS_WIDTH(13)) memory_controller (
    .clk(clk_50mhz),
    .rst(rst),

    .spi_din(spi_din),
    .spi_dout(spi_dout),
    .spi_done(spi_done),
    .spi_selected(spi_selected),

    .mem_we(mem_we),
    .mem_din(mem_din),
    .mem_dout(8'h55),
    .mem_addr(mem_addr)
);

// Strip driver
strip_driver #(.INPUT_CLOCK_FREQ_MHZ(50),
               .BASE_ADDRESS(0),
               .MAX_LEDS(NUM_LEDS),
               .ADDRESS_WIDTH(ADDRESS_WIDTH)) strip_driver_1 (
    .clk(clk_50mhz),
    .rst(rst),
    .mem_addr(mem_addr_strip),
    .mem_data(mem_dout),
    .strip_out(PIN_1)
);

endmodule
