# MiniRISC ISA Specification
Version: 1.0
Status: Frozen
Author: Parshuram Deshpande

---

# 1. Project Goal

MiniRISC is an educational 8-bit processor designed to understand the complete ASIC design flow from:

RTL
→ Simulation
→ Synthesis
→ Static Timing Analysis
→ Physical Design
→ GDSII

The objective is correctness, modularity, and RTL-to-GDS implementation rather than maximum performance.

---

# 2. CPU Specification

| Parameter | Value |
|-----------|-------|
| Architecture | Single Cycle |
| Datapath Width | 8 bits |
| Instruction Width | 16 bits |
| Address Width | 8 bits |
| Register Count | 8 |
| Register Width | 8 bits |
| Endianness | Little Endian (Future) |
| Instruction Memory | 256 × 16 |
| Data Memory | 256 × 8 |
| Reset | Synchronous |
| Register Read | Asynchronous |
| Register Write | Synchronous |

---

# 3. Register File

| Register | Description |
|-----------|-------------|
| R0 | Constant Zero |
| R1-R7 | General Purpose Registers |

Design Decisions

- R0 is immutable.
- Two asynchronous read ports.
- One synchronous write port.
- Writes occur only on positive clock edge.

---

# 4. Memory Architecture

Word Addressable Instruction Memory

Instruction Width = 16 bits

Program Counter increments by

PC = PC + 1

Reason

- Simpler hardware
- Smaller adder
- Easier RTL
- Educational processor

---

# 5. Instruction Formats

## R-Type

```
15      12 11    9 8     6 5     3 2     0
+---------+--------+-------+-------+-------+
| opcode  |  rd    | rs1   | rs2   | funct |
+---------+--------+-------+-------+-------+
```

| Field | Bits |
|-------|------|
| opcode | 4 |
| rd | 3 |
| rs1 | 3 |
| rs2 | 3 |
| funct | 3 |

Used For

- ADD
- SUB
- AND
- OR
- XOR

---

## I-Type

```
15      12 11    9 8     6 5      0
+---------+--------+-------+---------+
| opcode  |  rd    | rs1   | imm[5:0]|
+---------+--------+-------+---------+
```

| Field | Bits |
|-------|------|
| opcode | 4 |
| rd | 3 |
| rs1 | 3 |
| immediate | 6 |

Immediate Range

-32 to +31

Used For

- ADDI
- LOAD
- STORE

Immediate is sign-extended to the datapath width.

---

# 6. Addressing Mode

Base Register + Offset

Effective Address

EA = Base Register + Immediate

Reason

- Supports stack pointer
- Supports local variables
- Used in real processors
- Reusable ALU

---

# 7. Branch Strategy

Branch Target

PC + Signed Offset

PC calculation performed using the ALU.

Reason

Reuse existing hardware instead of dedicated branch adder.

---

# 8. Immediate Generator

Input

16-bit Instruction

Output

8-bit Immediate

Characteristics

- Pure combinational
- Always produces an output
- R-Type instructions output zero
- I-Type instructions output sign-extended immediate

---

# 9. ALU

Datapath Width

8 bits

Receives

Operand A

Register File

Operand B

Register File or Immediate

Selected using ALU Source MUX.

---

# 10. Control Philosophy

Every module has exactly one responsibility.

Program Counter

Stores instruction address.

Instruction Memory

Provides instruction.

Decoder

Extracts instruction fields.

Immediate Generator

Extracts immediate value.

Register File

Stores architectural state.

ALU

Performs arithmetic and logic.

Control Unit

Generates control signals.

---

# 11. Design Philosophy

This processor prioritizes

- Simplicity
- Modularity
- Deterministic behaviour
- Easy verification
- RTL-to-GDS implementation

rather than performance.

---

# 12. Coding Guidelines

Language

SystemVerilog

RTL Rules

- Parameterized modules
- always_ff for sequential logic
- always_comb for combinational logic
- Self-checking testbenches
- Deterministic default outputs
- No magic numbers
- One module per file

---

# 13. Verification Strategy

Each module must include

- Self-checking testbench
- PASS / FAIL messages
- Boundary testing
- Reset testing
- Functional verification

Waveforms are used only for debugging.

---

# 14. Future Work

- Decoder
- Immediate Generator
- Control Unit
- ALU
- Data Memory
- Branch Unit
- Top Module
- Processor Integration
- Assembly Programs
- FPGA Validation
- RTL Synthesis
- Static Timing Analysis
- Floorplanning
- Placement
- CTS
- Routing
- GDSII Generation