    module top_cpu #(
        parameter INST_WIDTH = 16,
        parameter DATA_WIDTH = 8,
        parameter ADDR_WIDTH = 8,
        parameter REG_DEPTH =  8,
        parameter REG_WIDTH = 8,
        parameter DATA_DEPTH = 256
    )(
        input logic clk,
        input logic rst,
        output logic [7:0] debug_pc,
        output logic [7:0] debug_alu,
        output logic [7:0] debug_wb
    );


    assign debug_pc  = pc;
    assign debug_alu = alu_result;
    assign debug_wb  = wb_data;
    //---------------------------------
    // Fetch Signals
    //---------------------------------
    logic [ADDR_WIDTH-1:0] pc;
    logic [ADDR_WIDTH-1:0] next_pc;
    
    logic [INST_WIDTH-1:0] instruction;


    //---------------------------------
    // Decode Signals
    //---------------------------------

        logic [3:0] opcode;
    //  logic [2:0] rd;
    //  logic [2:0] rs1;
    //  logic [2:0] rs2;
        logic [2:0] funct;

        logic [2:0] rs1_addr;
        logic [2:0] rs2_addr;
        logic [2:0] rd_addr;


        logic  reg_write;

        logic [REG_WIDTH - 1:0] rs1_data;
        logic [REG_WIDTH - 1:0] rs2_data;

        //immediate_generator

        logic [DATA_WIDTH -1 : 0 ] immediate;

    logic alu_src;
    logic mem_read;
    logic mem_write;
    logic branch;
    logic jump;
    logic [2:0] alu_op;

    //---------------------------------
    // Execute Signals
    //---------------------------------

    logic [DATA_WIDTH-1 : 0] operand_b ;

    //alu


        logic zero;
        logic carry;
        logic overflow;
        logic negative;

    //---------------------------------
    // Memory Signals
    //---------------------------------


    logic [DATA_WIDTH- 1 :0] read_data;

    //---------------------------------
    // Write back
    //---------------------------------


        logic [DATA_WIDTH-1:0] alu_result;

        logic  wb_sel;

        logic [DATA_WIDTH-1:0] wb_data;

    // TODO: Replace with PC selection logic when
    // branch/jump instructions are implemented.
        assign next_pc = pc + 1;
        

    //fetch stage



    pc #(.pc_width(ADDR_WIDTH)) u_pc(.clk(clk) , .rst(rst) ,.next_pc(next_pc) , .pc(pc) );
        
    instruction_Memory #(.PC_WIDTH(ADDR_WIDTH) , .INST_WIDTH(INST_WIDTH)) u_im(.pc(pc) , .instruction(instruction));


    //---------------------------------
    // Instruction Decoder
    //---------------------------------

    imm_decoder #(.INST_WIDTH(INST_WIDTH))   u_dec(.instruction(instruction) , .opcode(opcode) , .rd(rd_addr) , .rs1(rs1_addr) ,.rs2(rs2_addr) , .funct(funct));

    immediate_generator #(.REG_WIDTH(REG_WIDTH) , .INST_WIDTH(INST_WIDTH)) u_imm(.instruction(instruction) , .opcode(opcode) , .immediate(immediate) );

        control_unit  uctrl(.opcode(opcode) ,.funct(funct) ,.reg_write(reg_write) ,.alu_src(alu_src) ,.mem_read(mem_read) ,.mem_write(mem_write),.branch(branch) , .jump(jump) , .alu_op(alu_op) , .wb_sel(wb_sel));


    Register_File #(.REG_DEPTH(REG_DEPTH) ,.REG_WIDTH(REG_WIDTH)) u_rf(.clk(clk) , .rst(rst) ,.rs1_addr(rs1_addr) , .rs2_addr(rs2_addr) ,.rd_addr(rd_addr) , .reg_write(reg_write) , .rd_data(wb_data) ,.rs1_data(rs1_data) , .rs2_data(rs2_data));

    //---------------------------------
    // Execute Stage
    //---------------------------------


    alu_operand_mux #(.DATA_WIDTH(DATA_WIDTH)) u_mux(.rs2_data(rs2_data) ,.immediate(immediate) ,.alu_src(alu_src) ,.operand_b(operand_b));


    alu #(.DATA_WIDTH(DATA_WIDTH)) u_alu(.op1(rs1_data) , .op2(operand_b) , .alu_op(alu_op) , .out(alu_result[ADDR_WIDTH-1 : 0]) , .zero(zero) , .carry(carry) ,.overflow(overflow) ,.negative(negative));


    //Memory stage

    data_memory  #(.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH) , .DATA_DEPTH(DATA_DEPTH)) u_dm(
        
        .clk(clk),
        .address(alu_result),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .write_data(rs2_data),
        .read_data(read_data)
        
    );

    //write_back Stage

    write_back_mux #(.DATA_WIDTH(DATA_WIDTH)) u_wb(.alu_result(alu_result),.mem_data(read_data), .wb_sel(wb_sel), .wb_data(wb_data));



        endmodule
