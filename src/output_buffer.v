module output_buffer #(
    parameter WORD_SIZE = 32
    )(
    input wire [WORD_SIZE - 1:0] data_in,
    input wire ctrl,
    output wire [WORD_SIZE - 1:0] data_out
    );
    
    assign data_out = ctrl == 1'b1 ? data_in : {WORD_SIZE{1'bz}};
    
endmodule 