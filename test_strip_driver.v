`timescale 10 ns / 1 ns

module test(
);

reg clk_50mhz, rst;

wire[12:0] mem_addr;
wire strip_out;

strip_driver #(.INPUT_CLOCK_FREQ(16000000), .MAX_LEDS(5)) test_strip_driver(
    .clk(clk_50mhz),
    .rst(rst),
    .mem_data(8'h13),
    .mem_addr(mem_addr),
    .strip_out(strip_out)
);

initial
begin
    $display($time, "STARTING SIMULATION");
    $dumpfile("test.vcd");
    $dumpvars(0, test_strip_driver);
    clk_50mhz=1'b0;
    rst=1'b1;
    #20 rst=1'b0;

    #2_000_000 $display($time, "STOPPING SIMULATION");
    $finish;
end

always
    #2 clk_50mhz=~clk_50mhz;
endmodule
