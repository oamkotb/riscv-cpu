module alu #(
    parameter  WORD_SIZE = 32
    )(
    input wire [WORD_SIZE - 1:0] arg_a,
    input wire [WORD_SIZE - 1:0] arg_b,
    input wire [3:0] alu_sel,
    output wire alu_zero_flag,
    output reg [WORD_SIZE - 1:0] alu_out
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

    assign alu_zero_flag = alu_out == 0 ? 1 : 0;

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
              SLT: alu_out = ($signed(arg_a) < $signed(arg_b)) ? 1 : 0;
              SLTU: alu_out = (arg_a < arg_b) ? 1 : 0;
              default: alu_out = 0;
        endcase
    end

endmodule
