module register_file (
    input wire [4:0] A1, // Address for data going to output A
    input wire [4:0] A2, // Address for data going to output B
    input wire [4:0] A3, // Address for data being written
    input wire [31:0] write_data,
    input wire write_enable,
    input wire clk,
    input wire rst,
    output wire [31:0] A_out,
    output wire[31:0] B_out
    );
    
    reg [31:0] register_list[31:0];
    reg [5:0] i;
    
    assign A_out = A1 == 5'd0 ? 32'd0 : register_list[A1];
    assign B_out = A2 == 5'd0 ? 32'd0 : register_list[A2];
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                register_list[i] <= 32'd0;
            end    
        end
        else begin
            if (write_enable && A3 != 5'b00000) begin
                register_list[A3] <= write_data;
            end
        end
    end

endmodule