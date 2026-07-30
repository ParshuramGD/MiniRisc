"""Main driver for the MiniRISC assembler."""

from __future__ import annotations

import argparse
from pathlib import Path

from .encoder import encode_instruction, to_hex_string
from .parser import parse_instruction
from .tokenizer import tokenize


def assemble_file(input_path: str | Path, output_path: str | Path | None = None) -> list[str]:
    input_path = Path(input_path)
    if output_path is None:
        output_path = input_path.with_suffix(".hex")
    output_path = Path(output_path)

    machine_code_lines: list[str] = []

    with input_path.open("r", encoding="utf-8") as source:
        for raw_line in source:
            line = raw_line.strip()
            if not line or line.startswith("#"):
                continue

            tokens = tokenize(line)
            if not tokens:
                continue

            instruction = parse_instruction(tokens)
            word = encode_instruction(instruction)
            machine_code_lines.append(f"{to_hex_string(word)}")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("\n".join(machine_code_lines) + ("\n" if machine_code_lines else ""), encoding="utf-8")
    return machine_code_lines


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="python -m assembler", description="MiniRISC assembler")
    parser.add_argument("input", help="Input assembly file (.asm)")
    parser.add_argument("-o", "--output", help="Output hex file (.hex)")
    args = parser.parse_args(argv)

    input_path = Path(args.input)
    output_path = Path(args.output) if args.output else input_path.with_suffix(".hex")

    print("MiniRISC Assembler v1.0")
    print(f"Reading : {input_path}")

    machine_code_lines = assemble_file(input_path, output_path)

    print(f"Encoding: {len(machine_code_lines)} instructions")
    print(f"Output  : {output_path}")
    print("Assembly completed successfully.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
