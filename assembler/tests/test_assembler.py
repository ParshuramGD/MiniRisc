import pytest

from assembler.assembler import assemble_file
from assembler.encoder import encode_instruction, to_hex_string
from assembler.parser import Instruction, parse_instruction


def test_r_type_encoding() -> None:
    instruction = Instruction(mnemonic="ADD", rd=3, rs1=1, rs2=2)
    word = encode_instruction(instruction)
    assert word == 0x0650
    assert to_hex_string(word) == "0650"


def test_i_type_encoding() -> None:
    instruction = Instruction(mnemonic="ADDI", rd=1, rs1=0, imm=5)
    word = encode_instruction(instruction)
    assert word == 0x1205
    assert to_hex_string(word) == "1205"


def test_file_assembly(tmp_path) -> None:
    asm_path = tmp_path / "program.asm"
    hex_path = tmp_path / "program.hex"
    asm_path.write_text("ADDI R1,R0,#5\nADD R3,R1,R2\n", encoding="utf-8")

    output = assemble_file(asm_path, hex_path)

    assert output == ["1205", "0650"]


def test_unknown_register_is_rejected() -> None:
    with pytest.raises(ValueError, match="Unknown register"):
        parse_instruction(["ADD", "R8", "R1", "R2"])


def test_unknown_mnemonic_is_rejected() -> None:
    with pytest.raises(ValueError, match="Unknown mnemonic"):
        parse_instruction(["MUL", "R1", "R2", "R3"])


def test_immediate_out_of_range_is_rejected() -> None:
    with pytest.raises(ValueError, match="Immediate out of range"):
        parse_instruction(["ADDI", "R1", "R0", "#40"])
