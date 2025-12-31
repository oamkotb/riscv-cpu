module extend (
    input wire [31:0] inst,
    input wire [2:0] extend_sel,
    output reg [31:0] extend_out
    );

localparam ITYPE = 3'b001;
localparam STYPE = 3'b011;
localparam BTYPE = 3'b100;
localparam UTYPE = 3'b101;
localparam JTYPE = 3'b110;

always @(*) begin
    case (extend_sel)
        ITYPE: extend_out = {{20{inst[31]}}, inst[31:20]};
        STYPE: extend_out = {{20{inst[31]}}, inst[31:25], inst[11:7]};
        BTYPE: extend_out = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
        UTYPE: extend_out = {inst[31:12], 12'd0};
        JTYPE: extend_out = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
        default: extend_out = 32'd0;
    endcase
end

endmodule
