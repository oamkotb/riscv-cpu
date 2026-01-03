module combined_memory #(
    parameter WORD_SIZE = 32,
    parameter RAM_SIZE  = 1024
)(
    input  wire                 clk,
    input  wire                 rst,
    input  wire                 write_en,
    input  wire [WORD_SIZE-1:0] addr,
    input  wire [WORD_SIZE-1:0] write_data,
    output wire [WORD_SIZE-1:0] data
);
    localparam INTERNAL_ADDR_SIZE = $clog2(RAM_SIZE);
    // Byte addressable RAM
    reg  [7:0] RAM [0:RAM_SIZE-1];

    // Internal address signal
    wire [INTERNAL_ADDR_SIZE-1:0] addr_int;
    assign addr_int = addr[INTERNAL_ADDR_SIZE-1:0];

    // -------------------------------------------
    // Synchronous Write Process
    // -------------------------------------------
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // 1. Initialize all to zero (Optional, good for simulation)
            for (i = 0; i < 1024; i = i + 1) begin
                RAM[i] = 8'h00;
            end

            // 2. Load Hardcoded Instructions (Little Endian)

            // addi x1, x1, 21 -> 0x01508093
            RAM[0] = 8'h93;
            RAM[1] = 8'h80;
            RAM[2] = 8'h50;
            RAM[3] = 8'h01;

            // sw x1, 24(x0) -> 0x00102c23
            RAM[4] = 8'h23;
            RAM[5] = 8'h2c;
            RAM[6] = 8'h10;
            RAM[7] = 8'h00;

            // lw x2, 24(x0) -> 0x01802103
            RAM[8] = 8'h03;
            RAM[9] = 8'h21;
            RAM[10] = 8'h80;
            RAM[11] = 8'h01;

            // blt x1, x0, 8 -> 0x0000c463
            RAM[12] = 8'h63;
            RAM[13] = 8'hc4;
            RAM[14] = 8'h00;
            RAM[15] = 8'h00;

            // bge x1, x0, -16 -> 0xfe00d8e3
            RAM[16] = 8'he3;
            RAM[17] = 8'hd8;
            RAM[18] = 8'h00;
            RAM[19] = 8'hfe;

        end else if (write_en) begin
            // Write operations (only happen if not in reset)
            RAM[addr_int]     <= write_data[7:0];
            RAM[addr_int + 1] <= write_data[15:8];
            RAM[addr_int + 2] <= write_data[23:16];
            RAM[addr_int + 3] <= write_data[31:24];
        end
    end

    // -------------------------------------------
    // Asynchronous Read Process
    // -------------------------------------------
    assign data = {
        RAM[addr_int + 3],
        RAM[addr_int + 2],
        RAM[addr_int + 1],
        RAM[addr_int]
    };
endmodule
