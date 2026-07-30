# Program Counter (PC)

## Purpose

The Program Counter (PC) stores the address of the current instruction.
On every rising edge of the clock, it captures the next instruction address.

The PC is a sequential element and represents the architectural state of the processor.

---

## Architecture Decisions

- Width: 8 bits (parameterizable)
- Synchronous Reset
- Rising-edge triggered
- Word-addressable instruction memory
- No address calculation inside the module
- Pure state element

Reference:
ADR-015 Program Counter

---

## Interface

Inputs

clk

rst

next_pc [PC_WIDTH-1:0]

Outputs

pc [PC_WIDTH-1:0]

---

## RTL Behavior

if (rst)

↓

PC ← 0

else

↓

PC ← next_pc

---

## Verification

The following cases were verified.

✓ Synchronous reset

✓ Loading new PC values

✓ Multiple consecutive updates

✓ Reset after loading a value

✓ Maximum value (255)

✓ Minimum value (0)

---

## Simulation Result

PASS

All expected values matched waveform observations.

---

## Future Improvements

Version 2

Pipeline support

Version 5

Exception/Interrupt PC redirection

Version 6

Branch prediction support