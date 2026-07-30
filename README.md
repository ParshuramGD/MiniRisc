# MiniRISC

An educational yet industry-oriented 8-bit RISC processor built completely from scratch and taken through a complete RTL-to-GDSII ASIC design flow using open-source EDA tools.

## Overview

MiniRISC is a project to understand how real processors are designed, verified, synthesized, and implemented as silicon.

Rather than focusing only on writing RTL, this repository documents the complete hardware development process—from architectural decisions and ISA design to functional verification, synthesis, timing analysis, physical implementation, and final GDSII generation.

The project follows engineering practices used in the semiconductor industry, emphasizing architecture, modular RTL design, verification, and reproducible design flows.

---

## Features

- Custom 8-bit RISC Instruction Set Architecture
- 16-bit fixed-width instruction format
- Single-cycle processor implementation
- Modular datapath and control architecture
- Parameterized SystemVerilog RTL
- Self-checking testbenches
- Memory initialization using HEX files
- GTKWave waveform debugging
- Open-source RTL-to-GDSII flow

---

## Processor Architecture

- Program Counter (PC)
- Instruction Memory
- Register File (8 × 8-bit Registers)
- Immediate Generator
- ALU Operand Multiplexer
- Arithmetic Logic Unit (ALU)
- Data Memory
- Write Back Multiplexer
- Control Unit

---

## RTL Status

| Module | Status |
|---------|--------|
| Program Counter | ✅ Complete |
| Instruction Memory | ✅ Complete |
| Register File | ✅ Complete |
| Immediate Generator | ✅ Complete |
| ALU Operand MUX | ✅ Complete |
| ALU | ✅ Complete |
| Data Memory | ✅ Complete |
| Write Back MUX | ✅ Complete |
| Control Unit | ✅ Complete |
| Top CPU Integration | ✅ Complete |
| Top-Level Simulation | ✅ In Progress |

---

## Verification

- Module-level self-checking testbenches
- Top-level CPU verification
- GTKWave waveform analysis
- Memory initialization through HEX files
- Functional debugging using Icarus Verilog

---

## RTL-to-GDSII Flow

The processor is intended to be implemented using a complete open-source ASIC flow.

- RTL Simulation (Icarus Verilog)
- Waveform Debugging (GTKWave)
- Logic Synthesis
- Static Timing Analysis
- Floorplanning
- Placement
- Clock Tree Synthesis
- Routing
- DRC/LVS
- GDSII Generation

---

## Repository Structure

```
MiniRISC/
│
├── docs/               # Architecture documents and ISA
├── pkg/                # Global parameters and definitions
├── program/            # Instruction and data memory HEX files
├── rtl/                # SystemVerilog RTL modules
├── tb/                 # Testbenches
├── simulations/        # Simulation outputs
├── scripts/            # Build and automation scripts
└── README.md
```

---

## Development Roadmap

- [x] Architecture Specification
- [x] ISA Design
- [x] Datapath Design
- [x] Control Unit Design
- [x] RTL Implementation
- [x] Module Verification
- [ ] Complete Top-Level Functional Verification
- [ ] SystemVerilog Assertions
- [ ] Logic Synthesis
- [ ] Static Timing Analysis
- [ ] Physical Design
- [ ] DRC / LVS
- [ ] GDSII Generation

---

## Tools

- SystemVerilog
- Icarus Verilog
- GTKWave
- OpenLane
- OpenROAD
- OpenSTA
- Magic VLSI
- Netgen
- SKY130 Open PDK

---

## Long-Term Goal

Build an educational yet industry-quality processor that demonstrates the complete ASIC design flow—from architecture to manufacturable GDSII—using entirely open-source tools while following professional hardware engineering practices.
