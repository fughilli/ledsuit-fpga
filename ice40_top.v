module ice40_top (
    input CLK,
    input PIN_1,
    input PIN_2,
    input PIN_3,
    output PIN_4,
    output PIN_5,
    output USBPU
);

// Top-level constants
parameter NUM_LEDS = 72;
parameter NUM_DRIVERS = 2;
parameter NUM_CHANNELS = NUM_LEDS * 3;
parameter ADDRESS_WIDTH = $clog2(NUM_CHANNELS * NUM_DRIVERS) + 1;

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
wire[ADDRESS_WIDTH - 1:0] mem_data_addr;
reg[7:0] mem[0:NUM_CHANNELS*NUM_DRIVERS - 1];

wire[7:0] mem_dout;
assign mem_dout = mem[mem_data_addr];

wire mem_we;
wire[7:0] mem_din;
wire[ADDRESS_WIDTH - 1:0] mem_addr;

always @(posedge mem_we) begin
    mem[mem_addr] <= mem_din;
end

// SPI interface
wire[7:0] spi_dout;
wire[7:0] spi_din;
wire spi_done, spi_selected;

spi_slave spi_out (
    .clk(clk_50mhz),
    .rst(rst),

    .miso(),
    .mosi(PIN_3),
    .sck(PIN_2),
    .ss(PIN_1),

    .din(spi_din),
    .dout(spi_dout),

    .done(spi_done),
    .selected(spi_selected)
);

// SPI memory controller
spi_memory #(.ADDRESS_WIDTH(ADDRESS_WIDTH)) memory_controller (
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

// Strip drivers.
wire data_req_0;
wire data_rdy_0;
wire[7:0] data_0;
wire[ADDRESS_WIDTH - 1:0] data_addr_0;
wire strip_out_0;
strip_driver #(.INPUT_CLOCK_FREQ_MHZ(50),
               .MAX_LEDS(NUM_LEDS),
               .ADDRESS_WIDTH(ADDRESS_WIDTH)) strip_driver_0(
    .clk(clk_50mhz),
    .rst(rst),

    .mem_req(data_req_0),
    .mem_rdy(data_rdy_0),
    .mem_data(data_0),
    .mem_addr(data_addr_0),

    .strip_out(PIN_4)
);

wire data_req_1;
wire data_rdy_1;
wire[7:0] data_1;
wire[ADDRESS_WIDTH - 1:0] data_addr_1;
wire strip_out_1;
strip_driver #(.INPUT_CLOCK_FREQ_MHZ(50),
               .MAX_LEDS(NUM_LEDS),
               .ADDRESS_WIDTH(ADDRESS_WIDTH),
               .BASE_ADDRESS(NUM_CHANNELS)) strip_driver_1(
    .clk(clk_50mhz),
    .rst(rst),

    .mem_req(data_req_1),
    .mem_rdy(data_rdy_1),
    .mem_data(data_1),
    .mem_addr(data_addr_1),

    .strip_out(PIN_5)
);

bus_arbiter #(.ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(8)) bus_arbiter(
    .clk(clk_50mhz),
    .rst(rst),

    .data_req_0(data_req_0),
    .data_req_1(data_req_1),

    .data_addr_0(data_addr_0),
    .data_addr_1(data_addr_1),

    .data_0(data_0),
    .data_1(data_1),

    .data_rdy_0(data_rdy_0),
    .data_rdy_1(data_rdy_1),

    .mem_data_addr(mem_data_addr),
    .mem_data(mem_dout)
);

endmodule
