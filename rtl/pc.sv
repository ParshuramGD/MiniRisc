//------------------------------------------------------
// Module : Program Counter
// Description :
// Holds current instruction address.
//
// Type : Sequential
//
// Reset : Synchronous Active High
//------------------------------------------------------


module pc #(
    parameter int pc_width =8
)(
    input logic clk , 
    input logic rst ,
    input  logic  [pc_width-1:0] next_pc,

    output logic  [pc_width-1:0] pc
    
    );


always_ff @(posedge clk)
begin
if(rst)
pc <= {pc_width{1'b0}};
else
pc <= next_pc;


end

endmodule