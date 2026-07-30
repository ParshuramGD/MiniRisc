//------------------------------------------------------
// Module : ALU Operand MUX
//
// Description:
// Selects the second ALU operand.
// The operand is chosen from either the
// register file (rs2) or the immediate generator
// based on the alu_src control signal.
//
// Type : Pure Combinational
//------------------------------------------------------

module alu_operand_mux #(parameter DATA_WIDTH = 8)
(
input logic [DATA_WIDTH-1 :0] rs2_data,
input logic [DATA_WIDTH-1:0] immediate,
input logic alu_src,
output logic [DATA_WIDTH-1 : 0] operand_b

);

always_comb begin

operand_b = rs2_data;

if(alu_src)
operand_b = immediate;

end



endmodule
