//range and bus contain :
//global Macro
`define RstEnable    1'b1
`define Rstdisable    1'b0
`define ZeroWorld     32'h00000000 
`define Writeable   1'b1
`define Writedisable 1'b0
`define Readable    1'b1
`define Readdisable 1'b0
`define ChipEnable    1'b1
`define ChipDisable 1'b0 
`define True        1'b1
`define False       1'b0
`define Immbus      31:0
`define Immlen      32



//regfile Macro
`define RegAddrBus 4:0
`define RegBus     31:0
`define Regnum      32
`define Regnumlog2  5
`define RegWidth    32
`define NOPRegAddr  5'b00000

//Rom Macro
`define InstAddrBus 31:0// the width of Rom Address bus 
`define InstDataBus 31:0// the width of Rom Data bus
`define Dataaddress 31:0  


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
`define FUN3SLTIU 3'b011
`define FUN3XORI 3'b100
`define FUN3ORI 3'b110
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
`define FUN7SLLI 7'b0000000 
`define FUN7SRLI 7'b0000000 
`define FUN7SRAI 7'b0100000 
`define FUN7ADD 7'b0000000 
`define FUN7SUB 7'b0100000 
`define FUN7SLL 7'b0000000 
`define FUN7SLT 7'b0000000 
`define FUN7SLTU 7'b0000000 
`define FUN7XOR 7'b0000000 
`define FUN7SRL 7'b0000000 
`define FUN7SRA 7'b0100000 
`define FUN7OR 7'b0000000 
`define FUN7AND 7'b0000000 


//CMD
`define CmdLen 6
`define Cmd_Typebus 5:0
`define CmdLUI 6'b000001
`define CmdAUIPC 6'b000010
`define CmdJAL 6'b000011
`define CmdJALR 6'b000100
`define CmdBEQ 6'b000101
`define CmdBNE 6'b000110
`define CmdBLT 6'b000111
`define CmdBGE 6'b001000
`define CmdBLTU 6'b001001
`define CmdBGEU 6'b001010
`define CmdLB 6'b001011
`define CmdLH 6'b001100
`define CmdLW 6'b001101
`define CmdLBU 6'b001110
`define CmdLHU 6'b001111
`define CmdSB 6'b010000
`define CmdSH 6'b010001
`define CmdSW 6'b010010
`define CmdADDI 6'b010011
`define CmdSLTI 6'b010100
`define CmdSLTIU 6'b010101
`define CmdXORI 6'b010110
`define CmdORI 6'b010111
`define CmdANDI 6'b011000
`define CmdSLLI 6'b011001
`define CmdSRLI 6'b011010
`define CmdSRAI 6'b011011
`define CmdADD 6'b011100
`define CmdSUB 6'b011101
`define CmdSLL 6'b011110
`define CmdSLT 6'b011111
`define CmdSLTU 6'b100000
`define CmdXOR 6'b100001
`define CmdSRL 6'b100010
`define CmdSRA 6'b100011
`define CmdOR 6'b100100
`define CmdAND 6'b100101












