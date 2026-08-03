# MiniRISC

> **RTL-to-GDS implementation of an 8-bit Single-Cycle RISC Processor using SystemVerilog and the open-source ASIC design flow.**

MiniRISC is an educational yet industry-oriented processor project developed to understand the complete ASIC design lifecycle—from processor architecture and RTL implementation to synthesis, timing analysis, physical implementation, and final GDSII generation.

Unlike projects that stop at RTL simulation, MiniRISC follows the complete digital ASIC flow using open-source EDA tools while documenting the engineering concepts, reports, and artifacts generated at every stage.

---

# Project Goals

- Design an 8-bit single-cycle RISC processor from scratch.
- Develop modular, parameterized SystemVerilog RTL.
- Verify functionality using self-checking testbenches.
- Understand logic synthesis and static timing analysis.
- Learn the complete RTL-to-GDS implementation flow.
- Document every stage as an educational reference.

---

# Processor Specifications

| Parameter | Value |
|------------|-------|
| Architecture | Single-Cycle RISC |
| Datapath Width | 8-bit |
| Instruction Width | 16-bit |
| Register File | 8 × 8-bit |
| RTL Language | SystemVerilog |
| Clock Constraint | 10 ns |
| Technology | SKY130 HD Standard Cell Library |

---

# Processor Architecture

The processor consists of the following modules:

- Program Counter (PC)
- Instruction Memory
- Control Unit
- Register File
- Immediate Generator
- ALU Operand Multiplexer
- Arithmetic Logic Unit (ALU)
- Data Memory
- Write-Back Multiplexer

> *(Architecture diagram will be added here.)*

---

# Verification

Functional verification was performed using self-checking SystemVerilog testbenches.

Verification included:

- Module-level verification
- Top-level CPU verification
- GTKWave waveform analysis
- Memory initialization using HEX files
- Functional debugging with Icarus Verilog

---

# RTL-to-GDS Flow

MiniRISC was implemented through the complete open-source ASIC flow.

```text
RTL Design
    ↓
Functional Verification
    ↓
Logic Synthesis (Yosys)
    ↓
Static Timing Analysis (OpenSTA)
    ↓
Floorplanning
    ↓
Placement
    ↓
Clock Tree Synthesis
    ↓
Routing
    ↓
GDSII Generation
```

> **Note:** Physical implementation was executed using the OpenROAD-based Catalyzer flow. The objective of this project was to understand each implementation stage, analyze the generated reports, and study how an RTL design is transformed into a manufacturable layout rather than developing the underlying EDA algorithms.

---

# Implementation Results

| Metric | Value |
|---------|------:|
| Technology | SKY130 HD |
| Synthesized Cells | 135 |
| Clock Constraint | 10 ns |
| WNS | 0 ns |
| TNS | 0 ns |
| Die Size | 95.32 × 95.32 μm |
| Die Area | 9085.9 μm² |
| Core Utilization | 26% |
| Routing Overflow | 0 |
| DRC Errors | 0 |

---

# Repository Structure

```text
MiniRISC/
│
├── docs/                  # Documentation for each RTL-to-GDS stage
├── rtl/                   # SystemVerilog RTL
├── tb/                    # Self-checking testbenches
├── pkg/                   # Global definitions
├── constraints/           # Timing constraints
├── program/               # HEX initialization files
├── reports/               # Synthesis, STA and physical implementation reports
├── screenshots/           # Waveforms and layout images
├── scripts/               # Utility scripts
└── README.md
```

---

# Documentation

The repository documents each stage of the ASIC implementation flow.

- Project Overview
- Processor Architecture
- Functional Verification
- Logic Synthesis
- Static Timing Analysis
- Floorplanning
- Placement
- Clock Tree Synthesis
- Routing
- GDSII Generation
- Lessons Learned
- Interview Notes

---

# Tools

| Category | Tools |
|----------|-------|
| RTL Design | SystemVerilog |
| Simulation | Icarus Verilog |
| Waveform Debugging | GTKWave |
| Logic Synthesis | Yosys |
| Static Timing Analysis | OpenSTA |
| Physical Design | OpenROAD (Catalyzer Flow) |
| Layout Verification | Magic, Netgen |
| Technology | SKY130 Open PDK |

---

# Learning Outcome

This project was undertaken to understand the complete digital ASIC design flow. Rather than treating the physical design stages as a black box, the focus was on studying the reports, timing analysis, layout artifacts, and engineering decisions generated throughout the RTL-to-GDS implementation process.

---

# Future Improvements

- Multi-cycle processor
- Pipelined architecture
- Hazard detection and forwarding
- Interrupt support
- Cache integration
- SystemVerilog Assertions (SVA)
- Formal verification
- CI/CD automation for regression testing

---

# Acknowledgements

This project uses the open-source digital ASIC ecosystem, including Yosys, OpenSTA, OpenROAD, SKY130 Open PDK, and the Catalyzer RTL-to-GDS educational flow.
