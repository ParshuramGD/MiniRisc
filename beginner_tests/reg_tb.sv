module reg_tb;

    parameter reg_Width   = 8;   // Warning 10 implies your DUT expects 8 bits here
    parameter Reg_Depth   = 8;

    logic clk;
    logic rst;

    
    logic [2:0] rs1_addr;
    logic [2:0] rs2_addr;
    logic [2:0] rd_addr;


    logic  reg_write;
    logic [reg_Width - 1:0] rd_data;

    logic [reg_Width - 1:0] rs1_data;
    logic [reg_Width - 1:0] rs2_data;


Register_File #(.Reg_Depth(Reg_Depth) ,.reg_Width(reg_Width)) dut(.clk(clk) , .rst(rst) ,.rs1_addr(rs1_addr) , .rs2_addr(rs2_addr) ,.rd_addr(rd_addr) , .reg_write(reg_write) , .rd_data(rd_data) ,.rs1_data(rs1_data) , .rs2_data(rs2_data));


//dut owns the register array


initial begin

clk =0;
reg_write =0;
rs1_addr=0;
rs2_addr=0;

rst = 0;

forever  #5 clk =~clk;

end

initial begin
$monitor($time , " rst = %b , reg_write = %b  rs1 = %2d rs2 = %2d   , rd_data = %2d", rst , reg_write,  rs1_data ,rs2_data  ,rd_data  );
rst=1;

#0;
$display("test case 0 : check R0 immutablitlity " );
#10;
rst =0;

#10;

reg_write = 1'b1;

rd_addr = 3'd0;
rd_data = 8'd99;
#10;

reg_write = 1'b0;

rs1_addr = 3'd0;


rs2_addr = 3'd0;
#10;
$display("test case 1 : simultenous read ports " );

@(negedge clk);

reg_write = 1'b1;

rd_addr = 3'd4;
rd_data = 8'd12;

@(posedge clk);

@(negedge clk);

rd_addr = 3'd6;
rd_data = 8'd53;

@(posedge clk)

reg_write = 1'b0;

rs1_addr = 3'd4;
rs2_addr = 3'd6;

#10;

rs1_addr = 3'd4;
rs2_addr = 3'd4;



 #10;

@(posedge clk)
reg_write = 1'b0;

rs1_addr = 3'd4;

rd_addr = 3'd6;

rd_data = 8'd13;


rs2_addr = 3'b111;

#10;
rd_data = 8'd53;


   write_reg(4,12);

   write_reg(6,53);

read_reg(4,21);


end

//instead of writing huge lines of code for register


task write_reg(
    input [2:0] addr, input [7:0] data
);
begin
 @(negedge clk);
 reg_write = 1;
 rd_addr = addr;
 rd_data = data;

 @(posedge clk);
 reg_write =0;
 rd_addr = '0;  
 rd_data = '0;

 end

 endtask

task automatic read_reg(
    input [2:0] addr,
    input [7:0] expected
);

begin
//rs1_data is combinational after changing rs1_addr= addr 
//the simultero needs a delta cycle to update rs1_data
   rs1_addr = addr;
   #1;
   if(rs1_data !== expected)
   
   $error("Register %0d expected %0d got %0d " , addr , expected , rs1_data);

   end

   endtask




initial
begin
$dumpfile("reg_tb.vcd");

$dumpvars(0 , dut);


#100 

$finish;
end


endmodule



