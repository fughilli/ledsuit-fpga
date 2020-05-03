`timescale 10 ns / 1 ns

module test_ice40_top(
);

reg clk_50mhz, rst;

wire[12:0] mem_addr;
wire strip_out;

ice40_top top(
    .CLK(clk_50mhz),
    .PIN_1(strip_out),
    .USBPU()
);

integer i;

initial
begin
    $display($time, "STARTING SIMULATION");
    $dumpfile("test.vcd");
    $dumpvars(0, top);
    $dumpvars(0, test_ice40_top.top.mem[0]);
    $dumpvars(0, test_ice40_top.top.mem[1]);
    $dumpvars(0, test_ice40_top.top.mem[2]);
    $dumpvars(0, test_ice40_top.top.mem[3]);
    $dumpvars(0, test_ice40_top.top.mem[4]);
    $dumpvars(0, test_ice40_top.top.mem[5]);
    $dumpvars(0, test_ice40_top.top.mem[6]);
    $dumpvars(0, test_ice40_top.top.mem[7]);
    $dumpvars(0, test_ice40_top.top.mem[8]);

    for(i=0;i<72*3;i=i+1) begin
        test_ice40_top.top.mem[i] = 0;
    end

    clk_50mhz=1'b0;
    rst=1'b1;
    #20 rst=1'b0;

    #50_000_000 $display($time, "STOPPING SIMULATION");
    $finish;
end

always
    #2 clk_50mhz=~clk_50mhz;
endmodule
