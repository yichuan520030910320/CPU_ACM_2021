//range and bus contain :
//global Macro
`define RstEnable1    1'b1
`define Rstdisable    1'b0
`define ZeroWorld     32'h00000000 
`define Writeable   1'b1
`define Writedisable 0'b1
`define Readable    1'b1
`define Readdisable 0'b1
`define True        1'b1
`define False       0'b0


//regfile Macro
`define RegAddrBus 4:0
`define RegBus     31:0
`define Regnum      32
`define Regnumlog2  5
`define RegWidth    32
`define NOPRegAddr  5'b00000


//load from instruction
`define Opcoderange 6:0
`define Opcodesize  7
`define Rdrange 11:7
`define Rdsize  5
`define Funct3range 14:12
`define Funct3size  3
`define Rs1range 19:15
`define Rs1size  5
`define Rs2range 24:20
`define Rdsize  5
`define Funct7range 31:25
`define Funct7size  7

//opcode
`define OP_LUI 7'b0110111
`define OP_AUIPC 7'b0010111
`define OP_JAL 7'b1101111
`define OP_JALR 7'b1100111
`define OP_BRANCH 7'b1100011
`define OP_LOAD 7'b0000011
`define OP_STORE 7'b0100011
`define OP_ALU_IMM 7'b0010011
`define OP_ALU 7'b0110011

//FUNCT3
`define FUN3JALR 3'b000
`define FUN3BEQ 3'b000
`define FUN3BNE 3'b001
`define FUN3BLT 3'b100
`define FUN3BGE 3'b101
`define FUN3BLTU 3'b110
`define FUN3BGEU 3'b111
`define FUN3LB 3'b000
`define FUN3LH 3'b001
`define FUN3LW 3'b010
`define FUN3LBU 3'b100
`define FUN3LHU 3'b101
`define FUN3SB 3'b000
`define FUN3SH 3'b001
`define FUN3SW 3'b010
`define FUN3ADDI 3'b000
`define FUN3SLTI 3'b010
`define FUN3XORI 3'b011
`define FUN3ORI 3'b100
`define FUN3ANDI 3'b111
`define FUN3SLLI 3'b001
`define FUN3SRLI 3'b101
`define FUN3SRAI 3'b101
`define FUN3ADD 3'b000
`define FUN3SUB 3'b000
`define FUN3SLL 3'b001
`define FUN3SLT 3'b010
`define FUN3SLTU 3'b011
`define FUN3XOR 3'b100
`define FUN3SRL 3'b101
`define FUN3SRA 3'b101
`define FUN3OR 3'b110
`define FUN3AND 3'b111

//FUN7








