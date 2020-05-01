// One-hot demultiplexer. `select` is a one-hot encoded register that connects
// the n'th input to `output` when the n'th bit is hot.

module OneHotDemux(
    input[SELECT_WIDTH-1:0] select,
    input[DATA_WIDTH-1:0] demux_input_0,
    input[DATA_WIDTH-1:0] demux_input_1,
    input[DATA_WIDTH-1:0] demux_input_2,
    input[DATA_WIDTH-1:0] demux_input_3,
    input[DATA_WIDTH-1:0] demux_input_4,
    input[DATA_WIDTH-1:0] demux_input_5,
    input[DATA_WIDTH-1:0] demux_input_6,
    input[DATA_WIDTH-1:0] demux_input_7,
    output[DATA_WIDTH-1:0] demux_output
);

parameter SELECT_WIDTH=8;
parameter DATA_WIDTH=8;

assign demux_output = ((((8'b1) == (select))) ? (demux_input_0) : (((((8'b10) == (select))) ? (demux_input_1) : (((((8'b100) == (select))) ? (demux_input_2) : (((((8'b1000) == (select))) ? (demux_input_3) : (((((8'b10000) == (select))) ? (demux_input_4) : (((((8'b100000) == (select))) ? (demux_input_5) : (((((8'b1000000) == (select))) ? (demux_input_6) : (demux_input_7))))))))))))));

endmodule
