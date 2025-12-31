module mux_4to1 #(
    parameter WORD_SIZE = 32
)(
    input  wire [1:0]           sel,
    input  wire [WORD_SIZE-1:0] a,
    input  wire [WORD_SIZE-1:0] b,
    input  wire [WORD_SIZE-1:0] c,
    input  wire [WORD_SIZE-1:0] d,
    output wire [WORD_SIZE-1:0] out
);

    assign out = (sel == 2'b00) ? a :
                 (sel == 2'b01) ? b :
                 (sel == 2'b10) ? c :
                                  d;

endmodule
