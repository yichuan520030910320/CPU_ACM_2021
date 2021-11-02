`include "C:\Users\18303\Desktop\cpu\CPU_ACM_2021\riscv\src\define.v"
module ID (
    input  wire rst_in,

    input wire[`InstAddrBus] input_pc,
    input wire[`InstDataBus] input_instru,

    input  wire[`RegBus] reg1_data,
    input wire[`RegBus] reg2_data,
    
    output reg reg1_reador_not,
    output reg  reg2_reador_not,
    output reg[`RegAddrBus] reg1addr,
    output reg[`RegAddrBus] reg2addr,

    output reg[`RegBus] reg1_to_ex,
    output reg[`RegBus] reg2_to_ex,
    output reg[`RegAddrBus] rsd_to_ex,
    output reg write_rsd_or_not,
    output reg[`Cmd_Typebus] cmdtype_to_exe,
    output reg[`Immbus] imm_toex,
    output reg[`InstAddrBus] pc_out   
    
);

wire opcode=input_instru[6:0];
wire fun3=input_instru[14:12];
wire fun7=input_instru[31:25];
wire rd=input_instru[11:7];
wire rs1=input_instru[19:15];
wire rs2=input_instru[24:20];

reg[`RegBus] immreg;// record imm
reg instruvalid;//record if the instruct is valid



always @(*) begin
        reg1_reador_not=`False;
        reg2_reador_not=`False;
        reg1addr=5'b00000;
        reg2addr=5'b00000;
        reg1_to_ex=`ZeroWorld;
        reg2_to_ex=`ZeroWorld;
        reg1_to_ex=`ZeroWorld;
        write_rsd_or_not=`False;
        cmdtype_to_exe=6'b000000;
        imm_toex=`ZeroWorld;
        pc_out=`ZeroWorld;
    if (rst_in==`Rstdisable) begin
        
    end
    else
        begin
            case (opcode)
                `OP_LUI:
                begin
                    imm_toex={input_instru[31:12],12'h0};
                    write_rsd_or_not=`True;
                    cmdtype_to_exe=`CmdLUI;
                    
                                        
                end
                `OP_AUIPC:
                begin
                    
                end
                `OP_JAL:
                begin
                    
                end
                `OP_JALR:
                begin
                    
                end
                `OP_BRANCH:
                begin
                    
                end
                `OP_LOAD:
                begin
                    
                end
                `OP_STORE:
                begin
                    
                end
                `OP_ALU_IMM:
                begin
                    
                end
                `OP_ALU:
                begin
                    
                end
                default: 
                begin
                    
                end
            endcase
        end
end


endmodule //ID