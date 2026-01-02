module riscv_cpu_main(
    input wire clk,
    input wire rst
);
    wire        adr_src;
    wire        pc_write;
    wire        ir_write;
    wire        mem_write;
    wire        reg_write;
    wire        output_en;
    wire        zero_flag;
    wire [2:0]  out_mux_sel;
    wire [2:0]  imm_sel;
    wire [1:0]  alu_src_a_sel;
    wire [1:0]  alu_src_b_sel;
    wire [3:0]  alu_ctrl;
    wire [6:0]  opcode;
    wire [2:0]  funct3;
    wire [6:0]  funct7;
    wire [31:0] data_out;

    datapath_main #(.WORD_SIZE(32), .RAM_SIZE(1024)) datapath(
        .clk(clk),
        .rst(rst),
        .adr_src(adr_src),
        .pc_write(pc_write),
        .ir_write(ir_write),
        .mem_write(mem_write),
        .reg_write(reg_write),
        .output_en(output_en),
        .out_mux_sel(out_mux_sel),
        .imm_sel(imm_sel),
        .alu_src_a_sel(alu_src_a_sel),
        .alu_src_b_sel(alu_src_b_sel),
        .alu_ctrl(alu_ctrl),

        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .zero_flag(zero_flag),
        .data_out(data_out)
    );

    controller_main controller(
        .clk(clk),
        .rst(rst),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .zero_flag(zero_flag),
        .data_out(data_out),

        .adr_src(adr_src),
        .pc_write(pc_write),
        .ir_write(ir_write),
        .mem_write(mem_write),
        .reg_write(reg_write),
        .output_en(output_en),
        .out_mux_sel(out_mux_sel),
        .imm_sel(imm_sel),
        .alu_src_a_sel(alu_src_a_sel),
        .alu_src_b_sel(alu_src_b_sel),
        .alu_ctrl(alu_ctrl)
    );

endmodule
