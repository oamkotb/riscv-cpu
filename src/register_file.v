module register_file #(
    parameter WORD_SIZE = 32
    )(
    input  wire                   clk,
    input  wire                   rst,
    input  wire [4:0]             A1, // Address for data going to output A
    input  wire [4:0]             A2, // Address for data going to output B
    input  wire [4:0]             A3, // Address for data being written
    input  wire [WORD_SIZE - 1:0] write_data,
    input  wire                   write_en,

    output wire [WORD_SIZE - 1:0] A_out,
    output wire [WORD_SIZE - 1:0] B_out
    );
    reg [WORD_SIZE - 1:0] register_list[31:0];

    assign A_out = A1 == 5'd0 ? 0 : register_list[A1];
    assign B_out = A2 == 5'd0 ? 0 : register_list[A2];

    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                register_list[i] <= 0;
            end
        end
        else begin
            if (write_en && A3 != 5'b00000) begin
                register_list[A3] <= write_data;
            end
        end
    end

endmodule
