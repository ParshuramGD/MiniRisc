"""Parser for MiniRISC assembly instructions."""

from __future__ import annotations

from dataclasses import dataclass

from .isa import FUNCTS, I_TYPE_MNEMONICS, R_TYPE_MNEMONICS, REGISTERS


@dataclass(frozen=True)
class Instruction:
    mnemonic: str
    rd: int
    rs1: int
    rs2: int | None = None
    imm: int | None = None


def _parse_register(token: str) -> int:
    if token not in REGISTERS:
        raise ValueError(f"Unknown register '{token}'")
    return REGISTERS[token]


def parse_instruction(tokens: list[str]) -> Instruction:
    if not tokens:
        raise ValueError("Empty instruction")

    mnemonic = tokens[0].upper()
    if mnemonic not in FUNCTS and mnemonic not in I_TYPE_MNEMONICS:
        raise ValueError(f"Unknown mnemonic '{mnemonic}'")

    if len(tokens) != 4:
        raise ValueError(f"Expected 4 tokens for '{mnemonic}', got {len(tokens)}")

    if mnemonic in R_TYPE_MNEMONICS:
        rd = _parse_register(tokens[1])
        rs1 = _parse_register(tokens[2])
        rs2 = _parse_register(tokens[3])
        return Instruction(mnemonic=mnemonic, rd=rd, rs1=rs1, rs2=rs2)

    if mnemonic in I_TYPE_MNEMONICS:
        rd = _parse_register(tokens[1])
        rs1 = _parse_register(tokens[2])
        imm_token = tokens[3]
        if not imm_token.startswith("#"):
            raise ValueError(f"Immediate must be written as '#<value>' for '{mnemonic}'")
        imm = int(imm_token[1:])
        if imm < -32 or imm > 31:
            raise ValueError(f"Immediate out of range for '{mnemonic}': {imm}")
        return Instruction(mnemonic=mnemonic, rd=rd, rs1=rs1, imm=imm)

    raise ValueError(f"Unsupported instruction '{mnemonic}'")
