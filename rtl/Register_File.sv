module Register_File #(parameter REG_DEPTH = 8 , REG_WIDTH = 8)(

    input logic clk,
    input logic rst,

    
    input logic [2:0] rs1_addr,
    input logic [2:0] rs2_addr,
    input logic [2:0] rd_addr,

    input logic  reg_write,
    input logic [REG_WIDTH - 1:0] rd_data,

    output logic [REG_WIDTH - 1:0] rs1_data ,
    output logic [REG_WIDTH - 1:0] rs2_data
    
);


logic [REG_WIDTH - 1:0] registers [0:REG_DEPTH-1];

integer i;

always_ff @(posedge clk )
begin

if(rst)
for(i = 1 ; i < REG_DEPTH  ; i = i + 1)
registers[i] <= '0;

else

if(reg_write)
begin
if(rd_addr !=0)
registers[rd_addr] <= rd_data ;
end



end


assign rs1_data = (rs1_addr == 0) ?  0 :registers[rs1_addr] ;


assign rs2_data =(rs2_addr == 0) ?  0 : registers[rs2_addr];

endmodule