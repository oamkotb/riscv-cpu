module load_extend #(
    parameter WORD_SIZE = 32
)(
    input wire [WORD_SIZE-1:0] data,
    input wire [2:0] extend_sel,

    output reg [WORD_SIZE-1:0] extend_out
);
    // Encoding definitions
    localparam [2:0] BYTE  = 3'd0;
    localparam [2:0] HALF  = 3'd1;
    localparam [2:0] WORD  = 3'd2;
    localparam [2:0] UBYTE = 3'd3;
    localparam [2:0] UHALF = 3'd4;

    always @(*) begin
        case (extend_sel)
            // Signed Byte: Sign-extend
            BYTE:    extend_out = { {(WORD_SIZE-8){data[7]}}, data[7:0] };

            // Signed Half: Sign-extend
            HALF:    extend_out = { {(WORD_SIZE-16){data[15]}}, data[15:0] };

            // Word: Pass through
            WORD:    extend_out = data;

            // Unsigned Byte: Zero-extend
            UBYTE:   extend_out = { {(WORD_SIZE-8){1'b0}}, data[7:0] };

            // Unsigned Half: Zero-extend
            UHALF:   extend_out = { {(WORD_SIZE-16){1'b0}}, data[15:0] };

            default: extend_out = {WORD_SIZE{1'b0}};
        endcase
    end

endmodule
