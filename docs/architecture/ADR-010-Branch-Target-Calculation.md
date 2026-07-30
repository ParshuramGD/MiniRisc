# ADR-010: Branch Target Calculation Hardware

## Context
When executing a branch instruction (e.g., `BEQ`), the processor must calculate the target address (`PC + Offset`). We need to determine the hardware responsible for this addition. 

## Options Considered
1. **Dedicated Branch Adder:** Instantiate a separate adder exclusively for calculating branch targets.
2. **ALU Reuse:** Route the Program Counter and the immediate offset into the main ALU to compute the branch target.

## Decision
**Option 2 (ALU Reuse) is selected for Phase 1.**

## Rationale
Our current architectural goal is completing the full RTL-to-GDS flow. Prioritizing lower area and a simpler physical implementation is preferable. Reusing the ALU introduces a requirement for additional multiplexers at the ALU inputs, but saves the area and routing congestion of a dedicated 16-bit adder. This trade-off is optimal for a single-cycle design. A dedicated branch adder will be reconsidered when the architecture evolves to a pipelined implementation.
