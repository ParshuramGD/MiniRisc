    //------------------------------------------------------
    // Module : control unit
    //
    // Description:
    // given the instruction , what should every hardware block do during this clock cycle
    //------------------------------------------------------
    // Generates datapath control signals based on
    // decoded opcode and function fields.
    // This module contains no sequential logic and
    // does not store architectural state.
    //------------------------------------------------------
    // Type : Pure Combinational

    //------------------------------------------------------


    module control_unit (


        input logic [3:0] opcode,
        input logic [2:0] funct,
        output logic reg_write,
        output logic alu_src,
        output logic mem_read,
        output logic mem_write,
        output logic branch,
        output logic jump,
        output logic [2:0] alu_op,
        output logic wb_sel
    );

    `include "mini_risc_defines.svh"
        

    always_comb begin

        reg_write = 0;
        alu_src   = 0;
        mem_read  = 0;
        mem_write = 0;
        branch    = 0;
        jump      = 0;
        wb_sel    = 0;
        alu_op    = ALU_ILLEGAL;

    case(opcode)

// R-type ALU operations
    OPCODE_RTYPE :
    begin

    reg_write = 1;

    case( funct)

    ALU_ADD :alu_op = ALU_ADD;
    ALU_SUB : alu_op = ALU_SUB;
    ALU_AND : alu_op = ALU_AND;
    ALU_OR : alu_op = ALU_OR;
    ALU_XOR : alu_op = ALU_XOR;
    default : alu_op = ALU_ILLEGAL;

    endcase

    end
// Immediate arithmetic
    OPCODE_ADDI : begin
    reg_write = 1;
    alu_src = 1;

    alu_op = ALU_ADD;
    end

// Load from data memory
    OPCODE_LOAD : begin
    reg_write = 1;
    alu_src = 1;
    mem_read = 1;
    wb_sel = 1;
    alu_op = ALU_ADD;

    end

// Store to data memory
    OPCODE_STORE : begin

    alu_src =1;
    mem_write = 1;
    alu_op = ALU_ADD;
    end
// Unsupported opcode
    default : alu_op = ALU_ILLEGAL;

    endcase

    end
    endmodule