//------------------------------------------------------
// Module : Data Memory
//
// Description:
// Stores program data.
// Supports asynchronous reads and
// synchronous writes.
//
// Type:
// Read  : Combinational
// Write : Sequential
//------------------------------------------------------

module data_memory #(parameter DATA_WIDTH = 8 ,ADDR_WIDTH = 8, DATA_DEPTH =256)(

    input logic clk,
    input logic [ADDR_WIDTH-1 : 0] address,
    input logic mem_read,
    input logic mem_write,
    input logic [DATA_WIDTH -1 : 0] write_data,
    output logic [DATA_WIDTH- 1 :0] read_data
    
);

//data_memory


logic [DATA_WIDTH - 1: 0] memory [0 : DATA_DEPTH-1];

parameter MEM_FILE = "program/data.hex";

integer i;

initial begin
    for (i = 0; i < DATA_DEPTH; i = i + 1)
        memory[i] = '0;

    $readmemh(MEM_FILE, memory);
end


always_ff @(posedge clk)
begin
if(mem_write)
memory[address] <= write_data;

end


always_comb begin

    read_data = '0;

    if (mem_read && !mem_write)   
        read_data = memory[address];

end

endmodule