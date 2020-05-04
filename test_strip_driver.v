`timescale 10 ns / 1 ns

module test(
);

reg clk_50mhz, rst;

parameter ADDRESS_WIDTH = 10;
parameter NUM_LEDS = 5;
parameter NUM_CHANNELS = NUM_LEDS * 3;

// Memory
wire[ADDRESS_WIDTH - 1:0] mem_addr;
reg[7:0] mem[0:NUM_CHANNELS - 1];

reg[7:0] mem_dout;
reg mem_rdy;
wire mem_req;

reg[7:0] mem_read_counter;
// Simulate a read delay to test strip driver memory request logic.
parameter MEM_READ_DELAY = 10;

always @(posedge clk_50mhz) begin
    if (rst) begin
        mem_rdy <= 0;
        mem_dout <= 0;
        mem_read_counter <= 0;
    end else begin
        if (mem_req) begin
            // There's an outstanding request
            if (!mem_rdy) begin
                if (mem_read_counter == MEM_READ_DELAY) begin
                    mem_read_counter <= 0;
                    // Data has not been served yet. Transfer bits from memory
                    // and mark ready flag.
                    mem_dout <= mem[mem_addr];
                    mem_rdy <= 1;
                end else begin
                    mem_read_counter <= mem_read_counter + 1;
                end
            end
        end else begin
            // Request line is clear. Clear ready bit.
            mem_rdy <= 0;
        end
    end
end

strip_driver #(.INPUT_CLOCK_FREQ_MHZ(50), .MAX_LEDS(NUM_LEDS), .ADDRESS_WIDTH(ADDRESS_WIDTH)) test_strip_driver(
    .clk(clk_50mhz),
    .rst(rst),

    .mem_req(mem_req),
    .mem_rdy(mem_rdy),
    .mem_data(mem_dout),
    .mem_addr(mem_addr),

    .strip_out(strip_out)
);

integer i;

initial
begin
    $display($time, "STARTING SIMULATION");
    $dumpfile("test.vcd");
    $dumpvars(0, test_strip_driver);
    $dumpvars(0, test);

    for(i=0; i<NUM_CHANNELS; i+=1) begin
        mem[i] = i;
    end

    clk_50mhz=1'b0;
    rst=1'b1;
    #20 rst=1'b0;

    #20_000_000 $display($time, "STOPPING SIMULATION");
    $finish;
end

always
    #2 clk_50mhz=~clk_50mhz;
endmodule
