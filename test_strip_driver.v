
`timescale 10 ns / 1 ns

module test(
);

reg clk_50mhz, rst;

parameter NUM_LEDS = 20;
parameter NUM_DRIVERS = 8;
parameter NUM_CHANNELS = NUM_LEDS * 3;
parameter ADDRESS_WIDTH = $clog2(NUM_CHANNELS * NUM_DRIVERS);


// Strip drivers.
wire data_req_0;
wire data_rdy_0;
wire[7:0] data_0;
wire[ADDRESS_WIDTH - 1:0] data_addr_0;
wire strip_out_0;

assign PIN_4 = strip_out_0;

strip_driver #(.INPUT_CLOCK_FREQ_MHZ(50),
               .MAX_LEDS(NUM_LEDS),
               .ADDRESS_WIDTH(ADDRESS_WIDTH),
               .BASE_ADDRESS(NUM_CHANNELS*0)) strip_driver_0(
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

assign PIN_5 = strip_out_1;

strip_driver #(.INPUT_CLOCK_FREQ_MHZ(50),
               .MAX_LEDS(NUM_LEDS),
               .ADDRESS_WIDTH(ADDRESS_WIDTH),
               .BASE_ADDRESS(NUM_CHANNELS*1)) strip_driver_1(
    .clk(clk_50mhz),
    .rst(rst),

    .mem_req(data_req_1),
    .mem_rdy(data_rdy_1),
    .mem_data(data_1),
    .mem_addr(data_addr_1),

    .strip_out(strip_out_1)
);
wire data_req_2;
wire data_rdy_2;
wire[7:0] data_2;
wire[ADDRESS_WIDTH - 1:0] data_addr_2;
wire strip_out_2;

assign PIN_6 = strip_out_2;

strip_driver #(.INPUT_CLOCK_FREQ_MHZ(50),
               .MAX_LEDS(NUM_LEDS),
               .ADDRESS_WIDTH(ADDRESS_WIDTH),
               .BASE_ADDRESS(NUM_CHANNELS*2)) strip_driver_2(
    .clk(clk_50mhz),
    .rst(rst),

    .mem_req(data_req_2),
    .mem_rdy(data_rdy_2),
    .mem_data(data_2),
    .mem_addr(data_addr_2),

    .strip_out(strip_out_2)
);
wire data_req_3;
wire data_rdy_3;
wire[7:0] data_3;
wire[ADDRESS_WIDTH - 1:0] data_addr_3;
wire strip_out_3;

assign PIN_7 = strip_out_3;

strip_driver #(.INPUT_CLOCK_FREQ_MHZ(50),
               .MAX_LEDS(NUM_LEDS),
               .ADDRESS_WIDTH(ADDRESS_WIDTH),
               .BASE_ADDRESS(NUM_CHANNELS*3)) strip_driver_3(
    .clk(clk_50mhz),
    .rst(rst),

    .mem_req(data_req_3),
    .mem_rdy(data_rdy_3),
    .mem_data(data_3),
    .mem_addr(data_addr_3),

    .strip_out(strip_out_3)
);
wire data_req_4;
wire data_rdy_4;
wire[7:0] data_4;
wire[ADDRESS_WIDTH - 1:0] data_addr_4;
wire strip_out_4;

assign PIN_8 = strip_out_4;

strip_driver #(.INPUT_CLOCK_FREQ_MHZ(50),
               .MAX_LEDS(NUM_LEDS),
               .ADDRESS_WIDTH(ADDRESS_WIDTH),
               .BASE_ADDRESS(NUM_CHANNELS*4)) strip_driver_4(
    .clk(clk_50mhz),
    .rst(rst),

    .mem_req(data_req_4),
    .mem_rdy(data_rdy_4),
    .mem_data(data_4),
    .mem_addr(data_addr_4),

    .strip_out(strip_out_4)
);
wire data_req_5;
wire data_rdy_5;
wire[7:0] data_5;
wire[ADDRESS_WIDTH - 1:0] data_addr_5;
wire strip_out_5;

assign PIN_9 = strip_out_5;

strip_driver #(.INPUT_CLOCK_FREQ_MHZ(50),
               .MAX_LEDS(NUM_LEDS),
               .ADDRESS_WIDTH(ADDRESS_WIDTH),
               .BASE_ADDRESS(NUM_CHANNELS*5)) strip_driver_5(
    .clk(clk_50mhz),
    .rst(rst),

    .mem_req(data_req_5),
    .mem_rdy(data_rdy_5),
    .mem_data(data_5),
    .mem_addr(data_addr_5),

    .strip_out(strip_out_5)
);
wire data_req_6;
wire data_rdy_6;
wire[7:0] data_6;
wire[ADDRESS_WIDTH - 1:0] data_addr_6;
wire strip_out_6;

assign PIN_10 = strip_out_6;

strip_driver #(.INPUT_CLOCK_FREQ_MHZ(50),
               .MAX_LEDS(NUM_LEDS),
               .ADDRESS_WIDTH(ADDRESS_WIDTH),
               .BASE_ADDRESS(NUM_CHANNELS*6)) strip_driver_6(
    .clk(clk_50mhz),
    .rst(rst),

    .mem_req(data_req_6),
    .mem_rdy(data_rdy_6),
    .mem_data(data_6),
    .mem_addr(data_addr_6),

    .strip_out(strip_out_6)
);
wire data_req_7;
wire data_rdy_7;
wire[7:0] data_7;
wire[ADDRESS_WIDTH - 1:0] data_addr_7;
wire strip_out_7;

assign PIN_11 = strip_out_7;

strip_driver #(.INPUT_CLOCK_FREQ_MHZ(50),
               .MAX_LEDS(NUM_LEDS),
               .ADDRESS_WIDTH(ADDRESS_WIDTH),
               .BASE_ADDRESS(NUM_CHANNELS*7)) strip_driver_7(
    .clk(clk_50mhz),
    .rst(rst),

    .mem_req(data_req_7),
    .mem_rdy(data_rdy_7),
    .mem_data(data_7),
    .mem_addr(data_addr_7),

    .strip_out(strip_out_7)
);

// Memory
wire[ADDRESS_WIDTH - 1:0] mem_data_addr;
wire[7:0] mem_data;
wire[ADDRESS_WIDTH - 1:0] waddr;
assign waddr = 0;

bram #(.MEMORY_SIZE(NUM_CHANNELS * NUM_DRIVERS), .DATA_WIDTH(8)) bram(
    .clk(clk_50mhz),

    .wen(1'b0),
    .wdata(8'b0),
    .waddr(waddr),

    .ren(1'b1),
    .rdata(mem_data),
    .raddr(mem_data_addr)
);

bus_arbiter #(.ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(8)) bus_arbiter(
    .clk(clk_50mhz),
    .rst(rst),

    // CHANNEL 0
    .data_req_0(data_req_0),
    .data_addr_0(data_addr_0),
    .data_0(data_0),
    .data_rdy_0(data_rdy_0),
    // CHANNEL 1
    .data_req_1(data_req_1),
    .data_addr_1(data_addr_1),
    .data_1(data_1),
    .data_rdy_1(data_rdy_1),
    // CHANNEL 2
    .data_req_2(data_req_2),
    .data_addr_2(data_addr_2),
    .data_2(data_2),
    .data_rdy_2(data_rdy_2),
    // CHANNEL 3
    .data_req_3(data_req_3),
    .data_addr_3(data_addr_3),
    .data_3(data_3),
    .data_rdy_3(data_rdy_3),
    // CHANNEL 4
    .data_req_4(data_req_4),
    .data_addr_4(data_addr_4),
    .data_4(data_4),
    .data_rdy_4(data_rdy_4),
    // CHANNEL 5
    .data_req_5(data_req_5),
    .data_addr_5(data_addr_5),
    .data_5(data_5),
    .data_rdy_5(data_rdy_5),
    // CHANNEL 6
    .data_req_6(data_req_6),
    .data_addr_6(data_addr_6),
    .data_6(data_6),
    .data_rdy_6(data_rdy_6),
    // CHANNEL 7
    .data_req_7(data_req_7),
    .data_addr_7(data_addr_7),
    .data_7(data_7),
    .data_rdy_7(data_rdy_7),

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
        if (((i % NUM_CHANNELS) < 2) || ((i % NUM_CHANNELS) >= (NUM_CHANNELS - 2))) begin
            bram.memory[i] = i;
        end else begin
            bram.memory[i] = 0;
        end
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