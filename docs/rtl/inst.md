# Instruction Memory (ROM)

## Overview

The Instruction Memory stores the program instructions executed by the MiniRISC processor. Given the current Program Counter (PC), it returns the corresponding 16-bit instruction.

This module behaves as a Read-Only Memory (ROM) in Version 1.

---

## Design Specification

| Property | Value |
|----------|-------|
| Module | instruction_memory |
| Language | SystemVerilog |
| Type | Combinational |
| Read | Asynchronous |
| Write | Not Supported |
| Width | 16-bit (parameterized) |
| Depth | 256 words (parameterized) |

---

## Architecture Decisions

- Instruction memory owns its internal storage.
- Instructions are loaded using `$readmemh()`.
- Asynchronous read supports the single-cycle CPU architecture.
- No write port is provided since program memory is read-only during execution.

Reference: **ADR-016 – Instruction Memory**

---

## Interface

### Inputs

| Signal | Width | Description |
|--------|------:|-------------|
| `pc` | `PC_WIDTH` | Current Program Counter |

### Outputs

| Signal | Width | Description |
|--------|------:|-------------|
| `instruction` | `INST_WIDTH` | Instruction stored at address `pc` |

---

## RTL Behavior

```
instruction = memory[pc]
```

The output updates immediately whenever the Program Counter changes.

---

## Memory Initialization

Program instructions are loaded during simulation using:

```systemverilog
$readmemh("program/program.hex", memory);
```

This allows different programs to be executed without modifying the RTL.

---

## Verification

| Test Case | Result |
|-----------|--------|
| Read Address 0 | ✅ Pass |
| Read Address 1 | ✅ Pass |
| Read Address 2 | ✅ Pass |
| Read Address 3 | ✅ Pass |
| Read Address 4 | ✅ Pass |
| Program loaded using `$readmemh()` | ✅ Pass |

---

## Simulation Waveform

*Add GTKWave screenshot here.*

---

## Synthesizability

- Synthesizable combinational ROM
- Parameterized memory depth and instruction width
- No inferred latches
- Compatible with RTL-to-GDS flow

---

## Future Improvements

**Version 2**
- Pipeline instruction fetch

**Version 5**
- Exception/interrupt vector support

**Version 6**
- Instruction cache interface

---

## Files

```
rtl/instruction_memory.sv
tb/inst_tb.sv
program/program.hex
```