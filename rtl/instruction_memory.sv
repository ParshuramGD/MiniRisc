//------------------------------------------------------
// Module : instruction_Memory
// Description :
// Given the Program counter , return the corresponding instruction.
//
// Type : combinational
//
// Read : ASynchronous Read
// Write : No write access
//------------------------------------------------------

module instruction_Memory #(parameter PC_WIDTH = 8 , INST_WIDTH = 16 , Mem_DEPTH = 256)
(
      
      input logic [PC_WIDTH-1:0] pc,
      
      output logic [INST_WIDTH-1:0] instruction


);

logic [INST_WIDTH - 1: 0] Memory [0:Mem_DEPTH - 1];
      

initial
begin
$readmemh("program/program.hex" ,Memory);
end

assign instruction = Memory[pc];

endmodule