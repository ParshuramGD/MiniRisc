module inst_tb;

    parameter PC_WIDTH   = 8;   // Warning 10 implies your DUT expects 8 bits here
    parameter INST_WIDTH = 16;
    parameter Mem_DEPTH       = 256;
logic [PC_WIDTH-1:0] pc;
logic [INST_WIDTH-1:0] instruction;



instruction_memory #(.PC_WIDTH(PC_WIDTH) , .INST_WIDTH(INST_WIDTH)) dut(.pc(pc) , .instruction(instruction));


logic [INST_WIDTH - 1: 0] Mem [0:Mem_DEPTH - 1 ];
      
integer i;

initial
begin

for ( i = 0; i < Mem_DEPTH ; i = i + 1)
begin

 Mem[i] = i;

end

$monitor($time , "pc = %8b , instruction = %16b " , pc ,instruction);


pc = 8'd1;
#10;
#10;

pc = 8'd2;

#10;

pc = 8'd3;

#10;

pc = 8'd4;

#10;


end



initial
begin
$dumpfile("inst_tb.vcd");

$dumpvars(0 , inst_tb);


#100 

$finish;
end


endmodule



