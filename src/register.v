module register #(
    parameter WORD_SIZE = 32
)(
    input  wire                 clk,
    input  wire                 write_en,
    input  wire                 rst,
    input  wire [WORD_SIZE-1:0] write_data,
    output reg  [WORD_SIZE-1:0] data
);

always @(posedge clk, rst) begin
    if (write_en)
        data <= write_data;
end

endmodule
