//------------------------------------------------------
// Module : immediate_deoder
// Description :
// generates decide the instruction type for register file , cpu ,immediate.
//
// Type : combinational
//
// 
//------------------------------------------------------



module imm_decoder #(parameter INST_WIDTH = 16)(
    input logic [INST_WIDTH- 1:0] instruction,
    output logic [3:0] opcode,
    output logic [2:0] rd,
    output logic [2:0] rs1,
    output logic [2:0] rs2,
    output logic [2:0] funct

);




assign opcode = instruction[15:12];
assign rd =  instruction[11:9];
assign rs1 = instruction[8:6];
assign rs2 = instruction[5:3];
assign funct = instruction[2:0];

endmodule