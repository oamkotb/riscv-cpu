module riscv_cpu_tb();

    reg clk;
    reg rst;

    initial begin
        clk = 0;
        rst = 1;
        #10 rst = 0;
    end

    always #5 clk = ~clk;

    riscv_cpu_main cpu(
        .clk(clk),
        .rst(rst)
    );

endmodule
