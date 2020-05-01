module OneHotCounter(
    input rst,
    input clk,
    input count
);

parameter WIDTH = 5;

reg[WIDTH-1:0] counter;

always @(posedge clk) begin
    if (rst) begin
        counter <= 1;
    end else begin
        if (count) begin
            counter <= {counter[WIDTH-2:0], counter[WIDTH-1]};
        end
    end
end

endmodule
