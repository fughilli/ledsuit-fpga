{% set num_drivers = 8 %}
{% set indices = range(num_drivers) %}
module ice40_top (
    input CLK,
    input PIN_1,
    input PIN_2,
    input PIN_3,
    {% for index in indices %}
    output PIN_{{index + 4}},
    {% endfor %}
    output USBPU
);

// Top-level constants
parameter NUM_LEDS = 300;
parameter NUM_DRIVERS = {{num_drivers}};
parameter NUM_CHANNELS = NUM_LEDS * 3;
parameter ADDRESS_WIDTH = $clog2(NUM_CHANNELS * NUM_DRIVERS);

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
wire mem_re;
wire[7:0] mem_rdata;
wire[ADDRESS_WIDTH - 1:0] mem_raddr;
wire mem_we;
wire[7:0] mem_wdata;
wire[ADDRESS_WIDTH - 1:0] mem_waddr;

assign mem_re = 1'b1;

bram #(.MEMORY_SIZE(NUM_CHANNELS * NUM_DRIVERS), .DATA_WIDTH(8)) bram(
    .clk(clk_50mhz),

    .wen(mem_we),
    .wdata(mem_wdata),
    .waddr(mem_waddr),

    .ren(mem_re),
    .rdata(mem_rdata),
    .raddr(mem_raddr)
);

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
    .mem_din(mem_wdata),
    .mem_dout(8'h55),
    .mem_addr(mem_waddr)
);

// Strip drivers.
{% for index in indices %}
wire data_req_{{index}};
wire data_rdy_{{index}};
wire[7:0] data_{{index}};
wire[ADDRESS_WIDTH - 1:0] data_addr_{{index}};
wire strip_out_{{index}};

assign PIN_{{index + 4}} = strip_out_{{index}};

strip_driver #(.INPUT_CLOCK_FREQ_MHZ(50),
               .MAX_LEDS(NUM_LEDS),
               .ADDRESS_WIDTH(ADDRESS_WIDTH),
               .BASE_ADDRESS(NUM_CHANNELS*{{index}})) strip_driver_{{index}}(
    .clk(clk_50mhz),
    .rst(rst),

    .mem_req(data_req_{{index}}),
    .mem_rdy(data_rdy_{{index}}),
    .mem_data(data_{{index}}),
    .mem_addr(data_addr_{{index}}),

    .strip_out(strip_out_{{index}})
);
{% endfor %}

bus_arbiter #(.ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(8)) bus_arbiter(
    .clk(clk_50mhz),
    .rst(rst),

    {% for index in indices %}
    // CHANNEL {{index}}
    .data_req_{{index}}(data_req_{{index}}),
    .data_addr_{{index}}(data_addr_{{index}}),
    .data_{{index}}(data_{{index}}),
    .data_rdy_{{index}}(data_rdy_{{index}}),
    {% endfor %}

    .mem_data_addr(mem_raddr),
    .mem_data(mem_rdata)
);

endmodule
