module alu (
    input wire [31:0] arg_a,
    input wire [31:0] arg_b,
    input wire [3:0] alu_sel,
    output reg [31:0] alu_out
    );

    localparam ADD  = 4'h1;
    localparam SUB  = 4'h2;
    localparam XOR  = 4'h3;
    localparam OR   = 4'h4;
    localparam AND  = 4'h5;
    localparam SLL  = 4'h6;
    localparam SRL  = 4'h7;
    localparam SRA  = 4'h8;
    localparam SLT  = 4'h9;
    localparam SLTU = 4'hA;

    always @(*) begin
        case (alu_sel)
              ADD: alu_out = arg_a + arg_b;
              SUB: alu_out = arg_a - arg_b;
              XOR: alu_out = arg_a ^ arg_b;
              OR: alu_out = arg_a | arg_b;
              AND: alu_out = arg_a & arg_b;
              SLL: alu_out = arg_a << arg_b[4:0];
              SRL: alu_out = arg_a >> arg_b[4:0];
              SRA: alu_out = $signed(arg_a) >>> arg_b[4:0];
              SLT: alu_out = ($signed(arg_a) < $signed(arg_b)) ? 32'd1 : 32'd0;
              SLTU: alu_out = (arg_a < arg_b) ? 32'd1 : 32'd0;
              default: alu_out = 32'd0;
        endcase
    end

endmodule
