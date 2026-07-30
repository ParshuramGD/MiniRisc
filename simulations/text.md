please check

//------------------------------------------------------
// Module : instruction_memory
// Description :
// Given the Program counter , return the corresponding instruction.
//
// Type : combinational
//
// Read : ASynchronous Read
// Write : No write access
//------------------------------------------------------

module instruction_memory #(parameter pc_width = 8 , inst_width = 16 , word = 256)
(
      
      input logic [pc_width-1:0] pc,
      
      input logic [inst_width - 1: 0] Mem [word - 1 :0],
      output logic [inst_width-1:0] instruction


);



assign instruction = Mem[pc];

endmodule

module inst_tb;

    parameter pc_width   = 8;   // Warning 10 implies your DUT expects 8 bits here
    parameter inst_width = 16;
    parameter word       = 256;
logic [pc_width-1:0] pc;
logic [inst_width - 1: 0] Mem [word - 1 :0];
logic [inst_width-1:0] instruction;



instruction_memory #(.pc_width(pc_width) , .inst_width(inst_width)) dut(.pc(pc) , .Mem(Mem) , .instruction(instruction));

integer i;
initial
begin

for ( i = 0; i < word ; i = i + 1)
begin

 Mem[i] = i;

end

$monitor($time , "pc = %8b , instruction = %16b " , pc ,instruction);
#10;

pc = 8'd1;

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

$dumpvars(0 , inst_tb);
$dumpfile("inst_tb.vcd");


#100 

$finish;
end


endmodule


VCD warning: tb/inst_tb.sv:53: $dumpfile called after $dumpvars started,
                               using existing file (dump.vcd).
                   0pc = xxxxxxxx , instruction = xxxxxxxxxxxxxxxx 
                  10pc = 00000001 , instruction = 0000000000000001 
                  20pc = 00000010 , instruction = 0000000000000010 
                  30pc = 00000011 , instruction = 0000000000000011 
                  40pc = 00000100 , instruction = 0000000000000100 
tb/inst_tb.sv:58: $finish called at 100 (1s) 





register file


PS C:\Users\HP\Desktop\Minirisc> iverilog -g2012 -o reg_out rtl/Register_File.sv tb/reg_tb.sv PS C:\Users\HP\Desktop\Minirisc> vvp reg_out VCD info: dumpfile reg_tb.vcd opened for output. 0 rst = 1 , reg_write = 0 rs1_data = 0 rs2_data = 0 , rd_data = x 10 rst = 0 , reg_write = 1 rs1_data = 0 rs2_data = 0 , rd_data = 12 16 rst = 0 , reg_write = 0 rs1_data = 0 rs2_data = 0 , rd_data = 0 20 rst = 0 , reg_write = 1 rs1_data = 0 rs2_data = 0 , rd_data = 53 26 rst = 0 , reg_write = 0 rs1_data = 0 rs2_data = 0 , rd_data = 0 30 rst = 0 , reg_write = 1 rs1_data = 0 rs2_data = 0 , rd_data = 23 36 rst = 0 , reg_write = 0 rs1_data = 0 rs2_data = 0 , rd_data = 0 40 rst = 0 , reg_write = 1 rs1_data = 0 rs2_data = 0 , rd_data = 44 46 rst = 0 , reg_write = 0 rs1_data = 0 rs2_data = 0 , rd_data = 0 50 rst = 0 , reg_write = 1 rs1_data = 0 rs2_data = 0 , rd_data = 21 56 rst = 0 , reg_write = 0 rs1_data = 12 rs2_data = 0 , rd_data = 0 PASS : R4 = 12 57 rst = 0 , reg_write = 0 rs1_data = 53 rs2_data = 0 , rd_data = 0 PASS : R6 = 53 58 rst = 0 , reg_write = 0 rs1_data = 0 rs2_data = 0 , rd_data = 0 ERROR: tb/reg_tb.sv:102: Register 0 expected 44 got 0 Time: 59 Scope: reg_tb.read_reg 59 rst = 0 , reg_write = 0 rs1_data = 12 rs2_data = 0 , rd_data = 0 ERROR: tb/reg_tb.sv:102: Register 4 expected 21 got 12 Time: 60 Scope: reg_tb.read_reg 60 rst = 0 , reg_write = 0 rs1_data = 12 rs2_data = 53 , rd_data = 0 PASS : R4=12 R6=53 tb/reg_tb.sv:144: $finish called at 100 (1s)