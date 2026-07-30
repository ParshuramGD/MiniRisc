
module alu #(parameter DATA_WIDTH = 8) (


    input logic [DATA_WIDTH-1:0] op1,
    input logic [DATA_WIDTH-1:0] op2,
    input logic [2:0] alu_op,
    output logic [DATA_WIDTH-1:0] out,
    output logic zero,
    output logic carry,
    output logic overflow,
    output logic negative
    
);

`include "mini_risc_defines.svh"

logic [DATA_WIDTH:0] alu_result_ext;


always @* 
begin


out      = '0;
carry    = 1'b0;
overflow = 1'b0;
negative = 1'b0;

case(alu_op)

ALU_ADD : begin

alu_result_ext = {1'b0 , op1 } + {1'b0 , op2};

carry = alu_result_ext[DATA_WIDTH];
out = alu_result_ext[DATA_WIDTH-1:0];

overflow = ((op1[DATA_WIDTH-1] == op2[DATA_WIDTH-1]) && (out[DATA_WIDTH-1] != op1[DATA_WIDTH-1]));


end

ALU_SUB :begin

alu_result_ext = {1'b0 , op1 } - {1'b0 , op2};
 out = alu_result_ext[DATA_WIDTH-1:0];

 //carry = (op1 < op2);
 overflow = (op1[DATA_WIDTH-1] != op2[DATA_WIDTH-1]) && (out[DATA_WIDTH-1] != op1[DATA_WIDTH-1]);

end

ALU_AND : out = op1 & op2;
ALU_OR : out = op1 | op2;
ALU_XOR : out = op1 ^ op2;


default : begin
out = '0;
end

endcase


zero = (out == '0);

negative = out[DATA_WIDTH-1];

end


endmodule



