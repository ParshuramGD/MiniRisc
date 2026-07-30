"""Shared helper utilities for the MiniRISC assembler."""

from __future__ import annotations


def normalize_mnemonic(token: str) -> str:
    return token.strip().upper()
