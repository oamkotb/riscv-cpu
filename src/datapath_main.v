module datapath_main #(
    parameter WORD_SIZE = 32,
    parameter RAM_SIZE = 1024
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        adr_src,
    input  wire        pc_write,
    input  wire        ir_write,
    input  wire        mem_write,
    input  wire        reg_write,
    input  wire        output_en,
    input  wire [2:0]  out_mux_sel,
    input  wire [2:0]  imm_sel,
    input  wire [1:0]  alu_src_a_sel,
    input  wire [1:0]  alu_src_b_sel,
    input  wire [3:0]  alu_ctrl,

    output wire [6:0]  opcode,
    output wire [2:0]  funct3,
    output wire [6:0]  funct7,
    output wire        zero_flag,
    output wire        alu_lt,
    output wire [31:0] data_out
);
    wire [WORD_SIZE-1:0] pc_out;
    wire [WORD_SIZE-1:0] adr_out;
    wire [WORD_SIZE-1:0] mem_data;
    wire [WORD_SIZE-1:0] inst;
    wire [WORD_SIZE-1:0] pc_reg_out;

    wire [WORD_SIZE-1:0] a_data, b_data;
    wire [WORD_SIZE-1:0] extend_out;

    wire [WORD_SIZE-1:0] a_reg_out, b_reg_out;
    wire [WORD_SIZE-1:0] alu_a, alu_b;
    wire [WORD_SIZE-1:0] alu_out;
    wire [WORD_SIZE-1:0] alu_reg_out;

    wire [WORD_SIZE-1:0] data_reg_out;

    wire [WORD_SIZE-1:0] out_bus;

    assign opcode = inst[6:0];
    assign funct3 = inst[14:12];
    assign funct7 = inst[31:25];

    /*
     * FETCH STAGE:
     * Program Counter, Address MUX, Instruction Memory
     */
    register #(.WORD_SIZE(WORD_SIZE)) pc(
        .clk(clk),
        .write_en(pc_write),
        .rst(rst),
        .write_data(out_bus),

        .data(pc_out)
    );

    mux_2to1 #(.WORD_SIZE(WORD_SIZE)) adr_mux(
        .sel(adr_src),
        .a(pc_out),
        .b(out_bus),

        .out(adr_out)
    );

    combined_memory #(.WORD_SIZE(WORD_SIZE), .RAM_SIZE(RAM_SIZE)) memory(
        .clk(clk),
        .rst(rst),
        .write_en(mem_write),
        .addr(adr_out),
        .write_data(b_reg_out),

        .data(mem_data)
    );

    register #(.WORD_SIZE(WORD_SIZE)) inst_reg(
        .clk(clk),
        .write_en(ir_write),
        .rst(rst),
        .write_data(mem_data),

        .data(inst)
    );

    register #(.WORD_SIZE(WORD_SIZE)) pc_reg(
        .clk(clk),
        .write_en(ir_write),
        .rst(rst),
        .write_data(pc_out),

        .data(pc_reg_out)
    );

    /*
     * DECODE STAGE:
     * Register File, Immediate Extension
     */
    register_file #(.WORD_SIZE(WORD_SIZE)) regfile(
        .clk(clk),
        .rst(rst),
        .A1(inst[19:15]),
        .A2(inst[24:20]),
        .A3(inst[11:7]),
        .write_data(out_bus),
        .write_enable(reg_write),

        .A_out(a_data),
        .B_out(b_data)
    );

    extend extend(
        .inst(inst),
        .extend_sel(imm_sel),

        .extend_out(extend_out)
    );

    /*
     * EXECUTE STAGE:
     * Operand Registers, ALU Source MUXs, ALU
     */
    register #(.WORD_SIZE(WORD_SIZE)) a_reg(
        .clk(clk),
        .write_en(1'b1),
        .rst(rst),
        .write_data(a_data),

        .data(a_reg_out)
    );

    register #(.WORD_SIZE(WORD_SIZE)) b_reg(
        .clk(clk),
        .write_en(1'b1),
        .rst(rst),
        .write_data(b_data),

        .data(b_reg_out)
    );

    mux_3to1 #(.WORD_SIZE(WORD_SIZE)) a_mux(
        .sel(alu_src_a_sel),
        .a(pc_reg_out),
        .b(pc_out),
        .c(a_reg_out),

        .out(alu_a)
    );

    mux_3to1 #(.WORD_SIZE(WORD_SIZE)) b_mux(
        .sel(alu_src_b_sel),
        .a(b_reg_out),
        .b(extend_out),
        .c(32'd4),

        .out(alu_b)
    );

    alu #(.WORD_SIZE(WORD_SIZE)) alu(
        .arg_a(alu_a),
        .arg_b(alu_b),
        .alu_sel(alu_ctrl),

        .alu_zero_flag(zero_flag),
        .alu_lt(alu_lt),
        .alu_out(alu_out)
    );

    register #(.WORD_SIZE(WORD_SIZE)) alu_reg(
        .clk(clk),
        .write_en(1'b1),
        .rst(rst),
        .write_data(alu_out),

        .data(alu_reg_out)
    );

    /*
     * MEMORY STAGE:
     * Operand Registers, ALU Source MUXs, ALU
     */
    register #(.WORD_SIZE(WORD_SIZE)) data_reg(
        .clk(clk),
        .write_en(1'b1),
        .rst(rst),
        .write_data(mem_data),

        .data(data_reg_out)
    );

    /*
     * OUTPUT STAGE:
     * Output MUX, Output Buffer
     */
    mux_3to1 #(.WORD_SIZE(WORD_SIZE)) out_mux(
        .sel(out_mux_sel),
        .a(alu_reg_out),
        .b(alu_out),
        .c(data_reg_out),

        .out(out_bus)
    );

    output_buffer #(.WORD_SIZE(WORD_SIZE)) datapath_out(
        .data_in(out_bus),
        .ctrl(output_en),

        .data_out(data_out)
    );

endmodule
