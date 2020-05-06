{% set num_channels = 8 %}
{% set indices = range(num_channels) %}

`timescale 10 ns / 1 ns

module test(
);

reg clk_50mhz, rst;

parameter NUM_LEDS = 20;
parameter NUM_DRIVERS = {{num_channels}};
parameter NUM_CHANNELS = NUM_LEDS * 3;
parameter ADDRESS_WIDTH = $clog2(NUM_CHANNELS * NUM_DRIVERS);


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

    {% for index in indices %}
    // CHANNEL {{index}}
    .data_req_{{index}}(data_req_{{index}}),
    .data_addr_{{index}}(data_addr_{{index}}),
    .data_{{index}}(data_{{index}}),
    .data_rdy_{{index}}(data_rdy_{{index}}),
    {% endfor %}

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
