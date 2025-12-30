module output_buffer (
    input wire [31:0] data_in,
    input wire ctrl,
    output wire [31:0] data_out
    );
    
    assign data_out = ctrl == 1'b1 ? data_in : 32'dz;
    
endmodule 