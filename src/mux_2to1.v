module mux_2to1 #(
    parameter WORD_SIZE = 32,
)(
    input  wire                 sel,
    input  wire [WORD_SIZE-1:0] a,
    input  wire [WORD_SIZE-1:0] b,
    output wire [WORD_SIZE-1:0] out
);

   assign out = sel ? b : a;

endmodule
