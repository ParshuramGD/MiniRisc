"""Frozen ISA tables for the MiniRISC assembler.

This module intentionally contains only lookup tables. The hardware RTL in
`pkg/mini_risc_pkg.sv` already defines the same values, so the assembler now
follows the same stable encoding contract.
"""

from __future__ import annotations

OPCODES = {
    "ADD": 0b0000,
    "SUB": 0b0000,
    "AND": 0b0000,
    "OR":  0b0000,
    "XOR": 0b0000,
    "ADDI": 0b0001,
    "LOAD": 0b0010,
    "STORE": 0b0011,
}

FUNCTS = {
    "ADD": 0b000,
    "SUB": 0b001,
    "AND": 0b010,
    "OR":  0b011,
    "XOR": 0b100,
}

REGISTERS = {f"R{i}": i for i in range(8)}
R_TYPE_MNEMONICS = {"ADD", "SUB", "AND", "OR", "XOR"}
I_TYPE_MNEMONICS = {"ADDI", "LOAD", "STORE"}
