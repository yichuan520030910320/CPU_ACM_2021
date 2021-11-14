`include "C:\Users\18303\Desktop\cpu\CPU_ACM_2021\riscv\src\define.v"
module ID (
    input  wire rst_in,

    input wire[`InstAddrBus] input_pc,
    input wire[`InstDataBus] input_instru,

    input  wire[`RegBus] reg1_data,
    input wire[`RegBus] reg2_data,

    //forwarding
    input  wire ex_forward_id_i,
    input  wire[`RegBus] ex_forward_data_i,
    input  wire[`RegAddrBus] ex_forward_addr_i, 

    input  wire mem_forward_id_i,
    input  wire[`RegBus] mem_forward_data_i,
    input  wire[`RegAddrBus] mem_forward_addr_i, 
        
    output reg reg1_reador_not,
    output reg  reg2_reador_not,
    output reg[`RegAddrBus] reg1addr,
    output reg[`RegAddrBus] reg2addr,

    output reg[`RegBus] reg1_to_ex,
    output reg[`RegBus] reg2_to_ex,
    output reg[`RegAddrBus] rsd_to_ex,
    output reg write_rsd_or_not,
    output reg[`Cmd_Typebus] cmdtype_to_exe,
    output reg[`Immbus] immout,
    
    output reg[`InstAddrBus] pc_out   
    
);

wire opcode=input_instru[6:0];
wire fun3=input_instru[14:12];
wire fun7=input_instru[31:25];


reg[`RegBus] immreg;// record imm
reg instruvalid;//record if the instruct is valid



always @(*) begin
        reg1_reador_not=`False;
        reg2_reador_not=`False;
        reg1addr=5'b00000;
        reg2addr=5'b00000;
        reg1_to_ex=`ZeroWorld;
        reg2_to_ex=`ZeroWorld;
        rsd_to_ex=`ZeroWorld;
        write_rsd_or_not=`False;
        cmdtype_to_exe=6'b000000;
        immreg=`ZeroWorld;
        immreg=`ZeroWorld;        
        pc_out=`ZeroWorld;
    if (rst_in==`RstEnable) begin        
    end
    else
        begin
            case (opcode)
                `OP_LUI:
                begin
                    immreg={input_instru[31:12],12'h0};
                    write_rsd_or_not=`True;
                    cmdtype_to_exe=`CmdLUI;
                    rsd_to_ex=input_instru[`Rdrange];                       
                end
                `OP_AUIPC:
                begin
                    immreg={input_instru[31:12],12'h0};
                    write_rsd_or_not=`True;
                    cmdtype_to_exe=`CmdAUIPC;
                    rsd_to_ex=input_instru[`Rdrange];                                      
                end
                `OP_JAL:
                begin
                    immreg={{12{input_instru[31]}},input_instru[19:12],input_instru[20],input_instru[30:25],input_instru[24:21],1'b0};
                    write_rsd_or_not=`True;
                    cmdtype_to_exe=`CmdJAL;
                    rsd_to_ex=input_instru[`Rdrange];                    
                end
                `OP_JALR:
                begin
                    immreg={{21{input_instru[31]}},input_instru[30:20]};
                    write_rsd_or_not=`True;
                    cmdtype_to_exe=`CmdJALR;
                    rsd_to_ex=input_instru[`Rdrange]; 
                    
                end
                `OP_BRANCH:
                begin
                    immreg={{12{input_instru[31]}},input_instru[7],input_instru[30:25],input_instru[11:8],1'b0};
                    reg1_reador_not=`True;
                    reg2_reador_not=`True;
                    reg1addr=input_instru[`Rs1range];
                    reg2addr=input_instru[`Rs2range];
                    write_rsd_or_not=`False;
                    case (fun3)
                        `FUN3BEQ:begin
                            cmdtype_to_exe=`CmdBEQ;
                        end
                        `FUN3BNE: begin
                            cmdtype_to_exe=`CmdBNE;
                        end
                        `FUN3BLT:begin
                            cmdtype_to_exe=`CmdBLT;
                        end
                        `FUN3BGE:begin
                            cmdtype_to_exe=`CmdBGE;
                        end
                        `FUN3BLTU:begin
                            cmdtype_to_exe=`CmdBLTU;
                        end
                        `FUN3BGEU:begin
                            cmdtype_to_exe=`CmdBGEU;
                        end
                        default: 
                        begin                            
                        end
                    endcase                    
                end
                `OP_LOAD:
                begin
                    immreg={{21{input_instru[31]}},input_instru[30:20]};
                    write_rsd_or_not=`True;
                    rsd_to_ex=input_instru[`Rdrange];
                    reg1_reador_not=`True;
                    reg1addr=input_instru[`Rs1range];
                    case (fun3)
                        `FUN3LB:begin
                            cmdtype_to_exe=`CmdLB;
                        end
                        `FUN3LH: begin
                            cmdtype_to_exe=`CmdLH;
                        end
                        `FUN3LW:begin
                            cmdtype_to_exe=`CmdLW;
                        end
                        `FUN3LBU:begin
                            cmdtype_to_exe=`CmdLBU;
                        end
                        `FUN3LHU:begin
                            cmdtype_to_exe=`CmdLHU;
                        end
                        default: 
                        begin                            
                        end
                    endcase
                end
                `OP_STORE:
                begin
                    immreg={{21{input_instru[31]}},input_instru[30:25],input_instru[11:8],input_instru[7]};
                    reg1_reador_not=`True;
                    reg2_reador_not=`True;
                    reg1addr=input_instru[`Rs1range];
                    reg2addr=input_instru[`Rs2range];
                    write_rsd_or_not=`False;
                    case (fun3)
                        `FUN3SB:begin
                            cmdtype_to_exe=`CmdSB;
                        end
                        `FUN3SH: begin
                            cmdtype_to_exe=`CmdSH;
                        end
                        `FUN3SW:begin
                            cmdtype_to_exe=`CmdSW;
                        end
                        default: 
                        begin                            
                        end
                    endcase                   
                end
                `OP_ALU_IMM:
                begin
                    immreg={{21{input_instru[31]}},input_instru[30:20]};
                    write_rsd_or_not=`True;
                    rsd_to_ex=input_instru[`Rdrange];
                    reg1_reador_not=`True;
                    reg1addr=input_instru[`Rs1range];
                    case (fun3)
                        `FUN3ADDI:begin
                            cmdtype_to_exe=`CmdADDI;
                        end
                        `FUN3SLTI: begin
                            cmdtype_to_exe=`CmdSLTI;
                        end
                        `FUN3SLTIU:begin
                            cmdtype_to_exe=`CmdSLTIU;
                        end
                        `FUN3XORI:begin
                            cmdtype_to_exe=`CmdXORI;
                        end
                        `FUN3ORI:begin
                            cmdtype_to_exe=`CmdORI;
                        end
                        `FUN3ANDI:begin
                            cmdtype_to_exe=`CmdANDI;
                        end
                        `FUN3ANDI:begin
                            cmdtype_to_exe=`CmdANDI;
                        end
                        `FUN3ANDI:begin
                            cmdtype_to_exe=`CmdANDI;
                        end
                        `FUN3ANDI:begin
                            cmdtype_to_exe=`CmdANDI;
                        end
                        `FUN3SLLI:begin
                            immreg={26'h0,input_instru[25:20]};
                            cmdtype_to_exe=`CmdSLLI;
                        end
                        `FUN3SRLI:begin
                            immreg={26'h0,input_instru[25:20]};
                            case (fun7)
                                `FUN7SRLI: cmdtype_to_exe=`FUN7SRLI;
                                `FUN7SRAI:cmdtype_to_exe=`FUN7SRAI;
                                default: ;
                            endcase
                        end
                        default: 
                        begin                            
                        end
                    endcase                   
                end
                `OP_ALU:
                begin
                    reg1_reador_not=`True;
                    reg2_reador_not=`True;
                    reg1addr=input_instru[`Rs1range];
                    reg2addr=input_instru[`Rs2range];
                    write_rsd_or_not=`True;
                    rsd_to_ex=input_instru[`Rdrange];
                    case (fun3)
                    'h0:begin
                        case (fun7)
                            `FUN7ADD: cmdtype_to_exe=`CmdAND;
                            `FUN7SUB:cmdtype_to_exe=`CmdSUB;
                            default: ;
                        endcase
                    end
                    `FUN3SLT:begin
                        cmdtype_to_exe=`CmdSLT;
                        
                    end
                    `FUN3SLTU:begin
                        cmdtype_to_exe=`CmdSLTU;                        
                    end
                    `FUN3XOR:begin
                        cmdtype_to_exe=`CmdXOR;
                        
                    end
                    `FUN3OR:begin
                        cmdtype_to_exe=`CmdOR;
                        
                    end
                    `FUN3AND:begin
                        cmdtype_to_exe=`CmdAND;                        
                    end
                    'h5:begin
                        case (fun7)
                            `FUN7ADD: cmdtype_to_exe=`CmdSRL;
                            `FUN7SUB:cmdtype_to_exe=`CmdSRA;
                            default: ;
                        endcase
                    end
                    default:;                        
                    endcase                    
                end
                default: 
                begin                    
                end
            endcase
        end
        immout=immreg;
end
//todo forwarding!

always @(*)begin
    if(rst_in==`RstEnable||reg1addr==0)begin
        reg1_to_ex=`ZeroWorld;
        
    end
    else if(reg1_reador_not==`True&&ex_forward_id_i==`True&&ex_forward_addr_i==reg1addr) begin
        reg1_to_ex=ex_forward_data_i;
    end
    else if(reg1_reador_not==`True&&mem_forward_id_i==`True&&mem_forward_addr_i==reg1addr) begin
        reg1_to_ex=mem_forward_data_i;
    end
    else if(reg1_reador_not==`True) begin
        reg1_to_ex=reg1_data;
        
    end
    else if(reg1_reador_not==`False) begin
        reg1_to_ex=`ZeroWorld;
        
    end
    else
        begin
            reg1_to_ex=`ZeroWorld;            
        end
end

always @(*)begin
    if(rst_in==`RstEnable||reg2addr==0)begin
        reg2_to_ex=`ZeroWorld;       
    end
    else if(reg2_reador_not==`True&&ex_forward_id_i==`True&&ex_forward_addr_i==reg2addr) begin
        reg2_to_ex=ex_forward_data_i;
    end
    else if(reg2_reador_not==`True&&mem_forward_id_i==`True&&mem_forward_addr_i==reg2addr) begin
        reg2_to_ex=mem_forward_data_i;
    end
    else if(reg2_reador_not==`True) begin
        reg2_to_ex=reg2_data;
        
    end
    else if(reg2_reador_not==`False) begin
        reg2_to_ex=`ZeroWorld;        
    end
    else
        begin
            reg2_to_ex=`ZeroWorld;            
        end
end


endmodule //ID