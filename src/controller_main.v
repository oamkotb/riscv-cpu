module controller_main(
    input  wire        clk,
    input  wire        rst,
    input  wire [6:0]  opcode,
    input  wire [2:0]  funct3,
    input  wire [6:0]  funct7,
    input  wire        zero_flag,
    input  wire [31:0] data_out,

    output reg        adr_src,
    output reg        pc_write,
    output reg        ir_write,
    output reg        mem_write,
    output reg        reg_write,
    output reg        output_en,
    output reg [2:0]  out_mux_sel,
    output reg [2:0]  imm_sel,
    output reg [1:0]  alu_src_a_sel,
    output reg [1:0]  alu_src_b_sel,
    output reg [3:0]  alu_ctrl
);
    // INSTRUCTION TYPES
    localparam [6:0] R_TYPE      = 7'b0110011;
    localparam [6:0] I_TYPE_ARTH = 7'b0010011; // ADDI, SLLI, SLTI, etc.
    localparam [6:0] I_TYPE_LOAD = 7'b0000011; // LB, LH, LHU, etc
    localparam [6:0] I_TYPE_JUMP = 7'b1100111; // JALR
    localparam [6:0] S_TYPE      = 7'b0100011;
    localparam [6:0] B_TYPE      = 7'b1100011;
    localparam [6:0] J_TYPE      = 7'b1101111;
    localparam [6:0] U_TYPE_LOAD = 7'b0110111; // LUI
    localparam [6:0] U_TYPE_PC   = 7'b0010111; // AUIPC
    localparam [6:0] H_TYPE      = 7'b1111111;

    // R_TYPE
    localparam [9:0] ADD   = {3'h0, 7'h00}; // {funct3, funct7}
    localparam [9:0] SUB   = {3'h0, 7'h20};
    localparam [9:0] XOR   = {3'h4, 7'h00};
    localparam [9:0] OR    = {3'h6, 7'h00};
    localparam [9:0] AND   = {3'h7, 7'h00};
    localparam [9:0] SLL   = {3'h1, 7'h00};
    localparam [9:0] SRL   = {3'h5, 7'h00};
    localparam [9:0] SRA   = {3'h5, 7'h20};
    localparam [9:0] SLT   = {3'h2, 7'h00};
    localparam [9:0] SLTU  = {3'h3, 7'h00};

    // I_TYPE_ARTH
    localparam [9:0] ADDI  = {3'h0, 7'hxx};
    localparam [9:0] XORI  = {3'h4, 7'hxx};
    localparam [9:0] ORI   = {3'h6, 7'hxx};
    localparam [9:0] ANDI  = {3'h7, 7'hxx};
    localparam [9:0] SLLI  = {3'h1, 7'h00}; // imm[5:11]=0x00
    localparam [9:0] SRLI  = {3'h5, 7'h00}; // imm[5:11]=0x00
    localparam [9:0] SRAI  = {3'h5, 7'h20}; // imm[5:11]=0x20
    localparam [9:0] SLTI  = {3'h2, 7'hxx};
    localparam [9:0] SLTIU = {3'h0, 7'hxx};

    // I_TYPE_LOAD
    localparam [9:0] LB    = {3'h0, 7'hxx};
    localparam [9:0] LH    = {3'h1, 7'hxx};
    localparam [9:0] LW    = {3'h2, 7'hxx};
    localparam [9:0] LBU   = {3'h4, 7'hxx};
    localparam [9:0] LHU   = {3'h5, 7'hxx};

    // S_TYPE
    localparam [9:0] SB    = {3'h0, 7'hxx};
    localparam [9:0] SH    = {3'h1, 7'hxx};
    localparam [9:0] SW    = {3'h2, 7'hxx};

    // B_TYPE
    localparam [9:0] BEQ  = {3'h0, 7'hxx};
    localparam [9:0] BNE  = {3'h1, 7'hxx};
    localparam [9:0] BLT  = {3'h4, 7'hxx};
    localparam [9:0] BGE  = {3'h5, 7'hxx};
    localparam [9:0] BLTU = {3'h6, 7'hxx};
    localparam [9:0] BGEU = {3'h7, 7'hxx};

    // J_TYPE & I_TYPE_JUMP
    // localparam [9:0] JAL   = {3'hx, 7'hxx};
    // localparam [9:0] JALR  = {3'h0, 7'hxx};

    // U_TYPE_LOAD & U_TYPE_PC
    // localparam [9:0] LUI   = {3'hx, 7'hxx};
    // localparam [9:0] AUIPC = {3'hx, 7'hxx};

    // H_TYPE
    // localparam [9:0] HLT = {3'hx, 7'hxx};

    // STATE TYPES
    localparam RESET      = 4'd0;
    localparam FETCH      = 4'd1;
    localparam DECODE     = 4'd2;
    localparam MEM_ADR    = 4'd3;
    localparam MEM_READ   = 4'd4;
    localparam JUMP       = 4'd5;
    localparam WRITE_BACK = 4'd6;
    localparam BRANCH     = 4'd7;
    localparam HALT       = 4'd8;

    reg [3:0] current_state;
    reg [3:0] next_state;

    wire [9:0] funct = {funct3, funct7};

    // SEQUENTIAL LOGIC
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= RESET;
        else
            current_state <= next_state;
    end

    // COMBINATIONAL LOGIC
    always @(*) begin
        /////////////////////////////////////////////////////////////////////////
        // BY DEFAULT THE SIGNALS ARE ADDING PC + 4 and NOT SHIFTING REGISTERS //
        /////////////////////////////////////////////////////////////////////////

        // BY DEFAULT DO NOT UPDATE PC OR INSTRUCTION REGISTERS
        pc_write = 1'b0;
        ir_write = 1'b0;

        // BY DEFAULT DO NOT WRITE TO MEMORY OR REGISTERS
        mem_write = 1'b0;
        reg_write = 1'b0;

        // MUX DEFAULTS
        adr_src       = 1'b0;
        alu_src_a_sel = 2'b01;
        alu_src_b_sel = 2'b10;
        out_mux_sel   = 2'b01;

        // SET ALU BY DEFAULT TO ADDITION
        alu_ctrl = 4'h1;

        // NEXT STATE LOGIC AND CURRENT CONTROL SIGNALS
        case(current_state)
            RESET: begin
                next_state = FETCH;
                pc_write = 1'b1;
                ir_write = 1'b1;
            end
            FETCH: begin
                next_state = DECODE;
            end
            DECODE: begin
                case(opcode)
                    R_TYPE: begin
                        next_state    = WRITE_BACK;
                        alu_src_a_sel = 2'b10;
                        alu_src_b_sel = 2'b00;
                        casex(funct)
                            ADD     : alu_ctrl = 4'h1;
                            SUB     : alu_ctrl = 4'h2;
                            XOR     : alu_ctrl = 4'h3;
                            OR      : alu_ctrl = 4'h4;
                            AND     : alu_ctrl = 4'h5;
                            SLL     : alu_ctrl = 4'h6;
                            SRL     : alu_ctrl = 4'h7;
                            SRA     : alu_ctrl = 4'h8;
                            SLT     : alu_ctrl = 4'h9;
                            SLTU    : alu_ctrl = 4'hA;
                            default : alu_ctrl = 4'h1;
                        endcase
                    end
                    I_TYPE_ARTH: begin
                        next_state    = WRITE_BACK;
                        alu_src_a_sel = 2'b10;
                        alu_src_b_sel = 2'b01;
                        imm_sel       = 3'b001;
                        casex(funct)
                            ADDI    : alu_ctrl = 4'h1;
                            XORI    : alu_ctrl = 4'h3;
                            ORI     : alu_ctrl = 4'h4;
                            ANDI    : alu_ctrl = 4'h5;
                            SLLI    : alu_ctrl = 4'h6;
                            SRLI    : alu_ctrl = 4'h7;
                            SRAI    : alu_ctrl = 4'h8;
                            SLTI    : alu_ctrl = 4'h9;
                            SLTIU   : alu_ctrl = 4'hA;
                            default : alu_ctrl = 4'h1;
                        endcase
                    end
                    I_TYPE_LOAD: begin
                        next_state    = MEM_ADR;
                        alu_src_a_sel = 2'b10;
                        alu_src_b_sel = 2'b01;
                        imm_sel       = 3'b001;
                        out_mux_sel   = 2'b00;
                    end

                    S_TYPE: begin
                        next_state    = MEM_ADR;
                        alu_src_a_sel = 2'b10;
                        alu_src_b_sel = 2'b01;
                        imm_sel       = 3'b011;
                        out_mux_sel   = 2'b00;
                    end
                    default: begin
                        next_state = RESET;
                    end
                endcase;
            end

            MEM_ADR: begin
                if (opcode == S_TYPE) begin
                    next_state  = WRITE_BACK;
                    adr_src     = 1'b1;
                    mem_write   = 1'b1;
                    out_mux_sel = 2'b00;
                    // ADD an input into the INST/DATA MEMORY TO SELECT B, H (MAKE sure DEFAULT is W)
                end
                else begin
                    next_state  = MEM_READ;
                    adr_src     = 1'b1;
                    out_mux_sel = 2'b00;
                    // ADD an input into the INST/DATA MEMORY TO SELECT B, H, UB, UH (MAKE sure DEFAULT is W)
                end
            end

            MEM_READ: begin
                next_state = WRITE_BACK;
                out_mux_sel = 2'b10;
                reg_write = 1'b1;
            end
            WRITE_BACK: begin
                next_state = FETCH;
                pc_write = 1'b1;
                ir_write = 1'b1;
            end
            JUMP: begin

            end
            BRANCH: begin

            end
            HALT: begin

            end

            default: begin
                next_state = current_state;
            end
        endcase
    end
endmodule
