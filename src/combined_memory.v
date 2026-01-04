module combined_memory #(
    parameter WORD_SIZE = 32,
    parameter RAM_SIZE  = 1024
)(
    input  wire                 clk,
    input  wire                 rst,
    input  wire                 write_en,
    input  wire [WORD_SIZE-1:0] addr,
    input  wire [WORD_SIZE-1:0] write_data,
    input  wire [1:0]           ctrl, // from funct3

    output wire [WORD_SIZE-1:0] data
);
    // CTRL Values
    localparam [1:0] BYTE  = 2'h0;
    localparam [1:0] HALF  = 3'h1;
    localparam [1:0] WORD  = 3'h2;

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

            // lw x6, 4(x9) -> 0x0044A303
            RAM[0] = 8'h03;
            RAM[1] = 8'hA3;
            RAM[2] = 8'h44;
            RAM[3] = 8'h00;

            // sw x6, 128(x9) -> 0x0864A023
            RAM[4] = 8'h23;
            RAM[5] = 8'hA0;
            RAM[6] = 8'h64;
            RAM[7] = 8'h08;

            // lw x2, 8(x0) -> 0x00802103
            RAM[8] = 8'h03;
            RAM[9] = 8'h21;
            RAM[10] = 8'hC0;
            RAM[11] = 8'h00;

            // add x8, x2, x6 -> 0x00610433
            RAM[12] = 8'h33;
            RAM[13] = 8'h04;
            RAM[14] = 8'h61;
            RAM[15] = 8'h00;

            // andi x8, x8, 0xFF -> 0x0FF47413
            RAM[16] = 8'h13;
            RAM[17] = 8'h74;
            RAM[18] = 8'hF4;
            RAM[19] = 8'h0F;

            // jalr x12, 44(x0) -> 0x02C00667
            RAM[20] = 8'h67;
            RAM[21] = 8'h06;
            RAM[22] = 8'hC0;
            RAM[23] = 8'h02;

            // auipc x10, 385279 -> 0x5e0ff517
            RAM[24] = 8'h17;
            RAM[25] = 8'hf5;
            RAM[26] = 8'h0f;
            RAM[27] = 8'h5e;

            // hlt -> 0x3F3F3F3F
            RAM[28] = 8'h3F;
            RAM[29] = 8'h3F;
            RAM[30] = 8'h3F;
            RAM[31] = 8'h3F;

            // --- BIT COUNTER SUBROUTINE (starts at address 44) ---

            // andi x3, x3, 0x00 -> 0x0001F193
            RAM[44] = 8'h93;
            RAM[45] = 8'hF1;
            RAM[46] = 8'h01;
            RAM[47] = 8'h00;

            // andi x9, x2, 0x01 -> 0x00117493
            RAM[48] = 8'h93;
            RAM[49] = 8'h74;
            RAM[50] = 8'h11;
            RAM[51] = 8'h00;

            // andi x2, x8, 0x01 -> 0x00147113
            RAM[52] = 8'h13;
            RAM[53] = 8'h71;
            RAM[54] = 8'h14;
            RAM[55] = 8'h00;

            // add x3, x3, x2 -> 0x002181B3
            RAM[56] = 8'hB3;
            RAM[57] = 8'h81;
            RAM[58] = 8'h21;
            RAM[59] = 8'h00;

            // srl x8, x8, x9 -> 0x00945433
            RAM[60] = 8'h33;
            RAM[61] = 8'h54;
            RAM[62] = 8'h94;
            RAM[63] = 8'h00;

            // bne x8, x0, -12 -> 0xFE041AE3
            RAM[64] = 8'hE3;
            RAM[65] = 8'h1A;
            RAM[66] = 8'h04;
            RAM[67] = 8'hFE;

            // jalr x2, 0(x12) -> 0x00060167
            RAM[68] = 8'h67;
            RAM[69] = 8'h01;
            RAM[70] = 8'h06;
            RAM[71] = 8'h00;

        end else if (write_en) begin
            case (ctrl)
                BYTE: begin
                    RAM[addr_int]     <= write_data[7:0];
                end

                HALF: begin
                    RAM[addr_int]     <= write_data[7:0];
                    RAM[addr_int + 1] <= write_data[15:8];
                end

                WORD: begin
                    RAM[addr_int]     <= write_data[7:0];
                    RAM[addr_int + 1] <= write_data[15:8];
                    RAM[addr_int + 2] <= write_data[23:16];
                    RAM[addr_int + 3] <= write_data[31:24];
                end

                default: begin
                    RAM[addr_int]     <= write_data[7:0];
                    RAM[addr_int + 1] <= write_data[15:8];
                    RAM[addr_int + 2] <= write_data[23:16];
                    RAM[addr_int + 3] <= write_data[31:24];
                end
            endcase
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
