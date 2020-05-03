module ice40_top (
    input CLK,
    output PIN_1,
    output USBPU
);

// Top-level constants
parameter NUM_LEDS = 72;
parameter NUM_CHANNELS = NUM_LEDS * 3;

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
wire[12:0] mem_addr_strip;
reg[7:0] mem[0:NUM_CHANNELS - 1];
wire[7:0] mem_dout;
assign mem_dout = mem[mem_addr_strip];

// Debug counter
reg[16:0] counter;
reg[7:0] channel_counter;
reg[7:0] write_value;
always @(posedge clk_50mhz) begin
    if (rst) begin
        counter <= 0;
        channel_counter <= 0;
        write_value <= 8'h03;
    end else begin
        counter <= counter + 1;
        if (counter == 0) begin
            if (channel_counter == (NUM_CHANNELS - 1)) begin
                channel_counter <= 0;
                write_value <= write_value ^ 8'h03;
            end else begin
                channel_counter <= channel_counter + 1;
            end
            mem[channel_counter] <= write_value;
        end
    end
end

// Strip driver
strip_driver #(.INPUT_CLOCK_FREQ_MHZ(50), .BASE_ADDRESS(0), .MAX_LEDS(NUM_LEDS)) strip_driver (
    .clk(clk_50mhz),
    .rst(rst),
    .mem_addr(mem_addr_strip),
    .mem_data(mem_dout),
    .strip_out(PIN_1)
);

endmodule
