//------------------------------------------------------
// Module : Immediate Generator
//
// Description:
// Extracts and sign-extends the immediate field from
// the instruction based on the instruction format.
//
// Type : Pure Combinational
//------------------------------------------------------

module immediate_generator #( REG_WIDTH = 8 , INST_WIDTH = 16 )(

//git commit: instruction dpes not need  register storage it only extracts bits from instruction
    input logic [INST_WIDTH - 1 : 0] instruction ,
    input logic [3:0] opcode,
    output logic [REG_WIDTH - 1 : 0] immediate     
 );
 localparam OPCODE_RTYPE = 4'b0000;
localparam OPCODE_ADDI  = 4'b0001;
localparam OPCODE_LOAD  = 4'b0010;
localparam OPCODE_STORE = 4'b0011;


assign  immediate  = ((OPCODE_ADDI == 1) | (OPCODE_LOAD == 1) | (OPCODE_STORE == 1)) ? {{2{instruction[5]}}, instruction[5:0]} : '0;


 endmodule