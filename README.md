# RISC-V Multi-Cycle Processor

**riscv-cpu** is a synthesizable, 32-bit Multi-Cycle RISC-V processor core implemented in Verilog.

This project implements the **RV32I** Base Integer Instruction Set architecture using a Finite State Machine (FSM) control unit. Unlike single-cycle architectures, this design splits instruction execution into distinct states (Fetch, Decode, Execute, Memory, Writeback) to reuse hardware resources like the ALU and simplify timing closure.

> **Architecture:** Multi-Cycle (FSM-based Control)
> **Memory Model:** Unified Instruction/Data Memory (von Neumann style access via `combined_memory`)

---

## ⚡ Features

-   **ISA Support:** Supports the RV32I base integer instruction set.
    -   R-Type: `add`, `sub`, `and`, `or`, `xor`, `sll`, `srl`, `sra`, `slt`, `sltu`
    -   I-Type Arithmetic: `addi`, `andi`, `ori`, `xori`, `slli`, `srli`, `srai`, `slti`, `sltiu`
    -   I-Type Load: `lb`, `lh`, `lw`, `lbu`, `lhu`
    -   S-Type: `sb`, `sh`, `sw`
    -   B-Type: `beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`
    -   U-Type: `lui`, `auipc`
    -   J-Type: `jal`, `jalr` (implied support via JUMP state logic)
-   **Control Unit:** 8-state FSM (`RESET`, `FETCH`, `DECODE`, `MEM_ADR`, `MEM_READ`, `JUMP`, `WRITE_BACK`, `HALT`)
-   **Datapath:**
    -   Dedicated registers for PC, Instruction (`ir`), Data, and ALU output to stabilize signals across cycles.
    -   Extend units for handling immediate values (`imm_extend`) and memory load data (`load_extend`).
---
## 🏗️ Architecture Details

### Control FSM
[cite_start]The processor uses a finite state machine (FSM) defined in `controller_main.v` to drive the datapath signals[cite: 13]. The state transition logic handles the multi-cycle execution steps:

* [cite_start]**FETCH:** Updates the Program Counter (PC) and loads the new instruction from memory into the Instruction Register (`ir_write`)[cite: 45, 58].
* [cite_start]**DECODE:** Decodes the opcode to determine the instruction type and prepares ALU source operands[cite: 45, 60].
* [cite_start]**EXECUTE:** Performed logically within specific instruction type states (e.g., `R_TYPE`, `I_TYPE_ARTH`) or the `JUMP` state where the ALU computes results or branch targets[cite: 60, 68, 80].
* [cite_start]**MEM_ADR:** Calculates the effective address for Load (`I_TYPE_LOAD`) and Store (`S_TYPE`) instructions[cite: 46, 75].
* [cite_start]**MEM_READ:** Reads data from memory for Load instructions before transitioning to Writeback[cite: 46, 118].
* [cite_start]**WRITE_BACK:** Writes the final result (from ALU or Memory) back to the register file and updates the PC for the next instruction[cite: 47, 120].
* [cite_start]**HALT:** A trap state for handling errors or specific halt instructions[cite: 48, 112].

### Datapath
The datapath (`datapath_main.v`) is designed with internal storage elements to stabilize signals across the multiple cycles of a single instruction execution:

* [cite_start]**Internal Registers:** Dedicated registers for the PC (`pc_reg`), Instruction (`inst_reg`), ALU Output (`alu_reg`), and Memory Data (`data_reg`) ensure data availability across different FSM states[cite: 137, 138, 146, 148].
* [cite_start]**ALU Muxing:** `mux_3to1` units control the ALU inputs (`alu_src_a_sel`, `alu_src_b_sel`), allowing the ALU to operate on the PC, register values, or immediate values depending on the current state[cite: 143, 144].
* [cite_start]**Unified Memory:** A single `combined_memory` module handles both instruction fetching and data access, arbitrated by the `adr_src` signal[cite: 135, 136].
