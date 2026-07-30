"""Tokenizer for the MiniRISC assembler."""

from __future__ import annotations

import re

TOKEN_RE = re.compile(r"#[+-]?\d+|[A-Za-z_][A-Za-z0-9_]*|[+-]?\d+", re.UNICODE)


def tokenize(line: str) -> list[str]:
    """Split one assembly line into tokens.

    Example:
        ADD R3,R1,R2 -> ["ADD", "R3", "R1", "R2"]
        ADDI R1,R0,#5 -> ["ADDI", "R1", "R0", "#5"]
    """

    comment_free = line.split(";", 1)[0].strip()
    if not comment_free:
        return []

    tokens = TOKEN_RE.findall(comment_free.replace(",", " "))
    return [token if token.startswith("#") else token.upper() for token in tokens]
