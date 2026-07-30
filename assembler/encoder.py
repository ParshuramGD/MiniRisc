"""Encoder for the MiniRISC assembler."""

from __future__ import annotations

from .isa import FUNCTS, OPCODES
from .parser import Instruction


def encode_instruction(instruction: Instruction) -> int:
    opcode = OPCODES[instruction.mnemonic]

    if instruction.imm is not None:
        imm = instruction.imm & 0b111111
        return ((opcode & 0b1111) << 12) | ((instruction.rd & 0b111) << 9) | ((instruction.rs1 & 0b111) << 6) | (imm & 0b111111)

    funct = FUNCTS[instruction.mnemonic]
    return (
        ((opcode & 0b1111) << 12)
        | ((instruction.rd & 0b111) << 9)
        | ((instruction.rs1 & 0b111) << 6)
        | ((instruction.rs2 & 0b111) << 3)
        | (funct & 0b111)
    )


def to_hex_string(instruction_word: int) -> str:
    return f"{instruction_word:04X}"
