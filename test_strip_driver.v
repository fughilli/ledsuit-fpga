`timescale 10 ns / 1 ns

module test(
);

reg clk_50mhz, rst;

parameter ADDRESS_WIDTH = 10;
parameter NUM_LEDS = 300;
parameter NUM_DRIVERS = 2;
parameter NUM_CHANNELS = NUM_LEDS * 3;


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

    .strip_out(strip_out_0)
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

    .strip_out(strip_out_1)
);

// Memory
wire[ADDRESS_WIDTH - 1:0] mem_data_addr;
reg[7:0] mem[0:NUM_CHANNELS*NUM_DRIVERS - 1];

wire[7:0] mem_data;
assign mem_data = mem[mem_data_addr];

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
    .mem_data(mem_data)
);

integer i;

initial
begin
    $display($time, "STARTING SIMULATION");
    $dumpfile("test.vcd");
    $dumpvars(0, test);

    for(i=0; i<NUM_CHANNELS*NUM_DRIVERS; i+=1) begin
        mem[i] = i;
    end

    clk_50mhz=1'b0;
    rst=1'b1;
    #20 rst=1'b0;

    #2_000_000 $display($time, "STOPPING SIMULATION");
    $finish;
end

always
    #2 clk_50mhz=~clk_50mhz;
endmodule
