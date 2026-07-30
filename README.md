# MiniRISC

A custom 8-bit processor designed from scratch, taken through a complete RTL-to-GDSII ASIC flow.

## Overview
MiniRISC is an exploration of computer architecture and physical design. The goal of this project is to document the entire lifecycle of a chip: from ISA definition and architectural trade-offs to RTL implementation, verification, synthesis, and physical layout using open-source EDA tools (OpenLane, OpenSTA, Magic).

This project treats the processor not as a software script, but as a physical piece of hardware, prioritizing documented architectural trade-offs over immediate coding.

## Current Status: Phase 1 (Architecture & Specification) - COMPLETE
* Defined the Instruction Set Architecture (ISA).
* Completed Architecture Decision Records (ADRs) for all major datapath and control components.
* Established the complete Datapath Architecture.

## Project Roadmap
- [x] **Phase 1:** Architecture & ISA Specification
- [ ] **Phase 2:** RTL Implementation (Verilog)
- [ ] **Phase 3:** Functional Verification (Testbenches & Assertions)
- [ ] **Phase 4:** Logic Synthesis & STA
- [ ] **Phase 5:** Physical Design (Floorplanning, Placement, CTS, Routing)
- [ ] **Phase 6:** Sign-off (DRC, LVS)

## Repository Structure
* `/docs/` - Architecture Decision Records (ADRs) and ISA specifications.
* `/rtl/` - Verilog design files (Pending Phase 2).
* `/tb/` - Testbenches and verification environments (Pending Phase 3).
* `/scripts/` - EDA tool constraints and configuration scripts (Pending Phase 4).
