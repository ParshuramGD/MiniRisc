//------------------------------------------------------
// Module : Write Back MUX
//
// Description:
// Selects the data written back into the Register File.
// The source is selected by the Control Unit.
//
// Type : Pure Combinational
//------------------------------------------------------
module write_back_mux #(
    parameter DATA_WIDTH = 8
)(
    input  logic [DATA_WIDTH-1:0] alu_result,
    input  logic [DATA_WIDTH-1:0] mem_data,

    input  logic wb_sel,

    output logic [DATA_WIDTH-1:0] wb_data
);

        
 `include "mini_risc_defines.svh"       

always_comb
begin

//wb_data ='0;

case(wb_sel)
WB_ALU : wb_data = alu_result;
WB_MEM : wb_data = mem_data;


default : wb_data = '0;

endcase


end

endmodule