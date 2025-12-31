module mux_3to1 #(
    parameter WORD_SIZE = 32
)(
    input  wire [1:0]           sel,
    input  wire [WORD_SIZE-1:0] a,
    input  wire [WORD_SIZE-1:0] b,
    input  wire [WORD_SIZE-1:0] c,
    output wire [WORD_SIZE-1:0] out
);

    always @(*) begin
        case (sel)
            2'b00:   out = a;
            2'b01:   out = b;
            2'b10:   out = c;
            default: out = {WORD_SIZE{1'bx}};
        endcase
    end

endmodule
