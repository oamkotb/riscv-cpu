module combined_memory #(
    parameter WORD_SIZE = 32,
    parameter RAM_SIZE  = 1024
)(
    input  wire                 clk,
    input  wire                 write_en,
    input  wire [WORD_SIZE-1:0] addr,
    input  wire [WORD_SIZE-1:0] write_data,
    output wire [WORD_SIZE-1:0] data
);
    localparam INTERNAL_ADDR_SIZE = $clog2(RAM_SIZE);

    // Byte addressable RAM
    reg  [7:0] RAM [0:RAM-1];

    // Internal address signal
    wire [INTERNAL_ADDR_SIZE-1:0] addr_int;
    assign addr_int = addr[INTERNAL_ADDR_SIZE-1:0];

    // -------------------------------------------
    // Memory Initialization
    // -------------------------------------------
    integer i;
    initial begin
        // Initialize all memory to 0
        for (i = 0; i < 1024; i = i + 1) begin
            RAM[i] = 8'h00;
        end
    end

    // -------------------------------------------
    // Synchronous Write Process
    // -------------------------------------------
    always @(posedge clk) begin
        if (write_en) begin
            RAM[addr_int]     <= write_data[7:0];
            RAM[addr_int + 1] <= write_data[15:8];
            RAM[addr_int + 2] <= write_data[23:16];
            RAM[addr_int + 3] <= write_data[31:24];
        end
    end

    // -------------------------------------------
    // Asynchronous Read Process
    // -------------------------------------------
    assign data <= {
        RAM[addr_int + 3],
        RAM[addr_int + 2],
        RAM[addr_int + 1],
        RAM[addr_int]
    };
endmodule
