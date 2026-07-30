# ADR-013: Single-Cycle Datapath Architecture

## Context
We need to define the physical routing of data between the Program Counter, Memories, Register File, and ALU. The datapath must support Arithmetic, Memory (Load/Store), and Branching instructions using a unified architecture.

## Decision
We will implement a unified datapath utilizing three primary multiplexers to route data effectively, controlled by a central Control Unit.

1. **MUX 1 (ALU Input A):** Selects between the `Register File` (for arithmetic/memory operations) and the `Program Counter` (for branch target calculations).
2. **MUX 2 (ALU Input B):** Selects between the `Register File` (for register-to-register arithmetic) and the `Immediate Generator` (for immediates and address offsets).
3. **MUX 3 (Write Back):** Selects between the `ALU Result` (for arithmetic) and `Memory Data` (for Load instructions) to be written back into the Register File.

## Rationale
This architecture maximizes hardware reuse. Instead of building independent paths for arithmetic and memory operations, a single ALU and multiplexed datapath can handle all instruction classes. This approach is both area-efficient and simplifies the Control Unit logic, making it ideal for the scope of Phase 1 (RTL-to-GDS completion).
