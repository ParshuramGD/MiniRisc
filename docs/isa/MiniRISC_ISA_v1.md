# MiniRISC Instruction Set Architecture (v1.0)

## Overview
MiniRISC utilizes a 16-bit instruction word length with a 4-bit opcode. It is a Load/Store architecture, meaning arithmetic operations only occur between registers.

## Registers
* **R0 - R7:** 8 General Purpose Registers (GPRs).
* **PC:** Program Counter.

## Instruction Formats
All instructions are 16 bits wide. The highest 4 bits `[15:12]` are always the Opcode.

| Format | `[15:12]` | `[11:9]` | `[8:6]` | `[5:3]` | `[2:0]` |
|--------|-----------|----------|---------|---------|---------|
| **R-Type** | Opcode | Dest Reg (Rd) | Src Reg 1 (Rs1) | Src Reg 2 (Rs2) | Unused |
| **I-Type** | Opcode | Dest Reg (Rd) | Src Reg 1 (Rs1) | Immediate (6-bit) |
| **M-Type** | Opcode | Dest Reg (Rd) | Base Reg (Rs1) | Offset (6-bit) |
| **B-Type** | Opcode | Src Reg 1 (Rs1) | Src Reg 2 (Rs2) | Offset (6-bit) |

## Base Instruction Set

### Arithmetic & Logic
* `ADD Rd, Rs1, Rs2` (Opcode: `0001`) - Adds Rs1 and Rs2, stores in Rd.
* `ADDI Rd, Rs1, Imm` (Opcode: `0010`) - Adds Rs1 and an immediate value, stores in Rd.

### Memory Access
* `LOAD Rd, [Rs1 + Offset]` (Opcode: `1000`) - Loads data from memory address (Rs1 + Offset) into Rd.
* `STORE Rs2, [Rs1 + Offset]` (Opcode: `1001`) - Stores data from Rs2 into memory address (Rs1 + Offset).

### Control Flow
* `BEQ Rs1, Rs2, Offset` (Opcode: `1100`) - Branches to (PC + Offset) if Rs1 equals Rs2.
