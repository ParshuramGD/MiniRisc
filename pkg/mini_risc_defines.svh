// ============================================================
// MiniRISC Shared Definitions
// Included inside every RTL module that needs opcodes/ALU ops
// ============================================================

// ---------------------- Opcodes ------------------------------

localparam OPCODE_RTYPE = 4'b0000;
localparam OPCODE_ADDI  = 4'b0001;
localparam OPCODE_LOAD  = 4'b0010;
localparam OPCODE_STORE = 4'b0011;

// ---------------------- ALU Operations -----------------------

localparam ALU_ADD      = 3'b000;
localparam ALU_SUB      = 3'b001;
localparam ALU_AND      = 3'b010;
localparam ALU_OR       = 3'b011;
localparam ALU_XOR      = 3'b100;
localparam ALU_RSVD1    = 3'b101;
localparam ALU_RSVD2    = 3'b110;
localparam ALU_ILLEGAL  = 3'b111;


// ---------------------- Write Back MUX -----------------------

localparam WB_ALU = 1'b0;
localparam WB_MEM = 1'b1;