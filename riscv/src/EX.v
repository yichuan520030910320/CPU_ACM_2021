`include "C:\Users\18303\Desktop\cpu\CPU_ACM_2021\riscv\src\define.v"
module EX (
    input  wire rst_in, 
    input wire[`RegBus] reg1_to_ex,
    input wire[`RegBus] reg2_to_ex,
    input wire[`RegAddrBus] rsd_to_ex,
    input wire write_rsd_or_not_to_ex,
    input wire[`Cmd_Typebus] cmdtype_to_exe,    
    input wire[`InstAddrBus] pc_in,
    input  wire[`Immbus] imm_in,

    output reg[`RegAddrBus] rsd_addr_to_write,
    output reg[`RegBus] rsd_data,
    output reg write_rsd_or_not,
    output reg branch_or_not,
    output reg[`InstAddrBus] branch_address       
);
always @(*) begin
    rsd_addr_to_write=5'h0;
    rsd_data=0;
    write_rsd_or_not=`False;
    branch_or_not=`False;
    branch_address=0;
    
    if (rst_in==`RstEnable)begin
        
    end
    else 
    begin
        case (cmdtype_to_exe)
        
        `CmdLUI:begin
            write_rsd_or_not=`True;
            rsd_data=imm_in;
            rsd_addr_to_write=rsd_to_ex;

            
        end          
        `CmdAUIPC:begin
            write_rsd_or_not=`True;
            rsd_data=imm_in+pc_in;
            rsd_addr_to_write=rsd_to_ex;           
        end          
        `CmdJAL:begin
            write_rsd_or_not=`True;
            rsd_data=4+pc_in;
            rsd_addr_to_write=rsd_to_ex;
            branch_or_not=`True;
            branch_address=pc_in+imm_in;               
        end          
        `CmdJALR:begin
            write_rsd_or_not=`True;
            rsd_data=4+pc_in;
            rsd_addr_to_write=rsd_to_ex;
            branch_or_not=`True;
            branch_address=(reg1_to_ex+imm_in)&~1;             
        end          
        `CmdBEQ:begin               
            if (reg1_to_ex==reg2_to_ex) begin
                branch_or_not=`True;
                branch_address=pc_in+imm_in;                 
            end
            
        end          
        `CmdBNE: begin               
            if (reg1_to_ex!=reg2_to_ex) begin
                branch_or_not=`True;
                branch_address=pc_in+imm_in;                 
            end            
        end           
        `CmdBLT: begin
            if ($signed(reg1_to_ex)<$signed(reg2_to_ex)) begin
                branch_or_not=`True;
                branch_address=pc_in+imm_in;                 
            end 
        end              
        `CmdBGE: begin
            if ($signed(reg1_to_ex)>=$signed(reg2_to_ex)) begin
                branch_or_not=`True;
                branch_address=pc_in+imm_in;                 
            end 
        end            
        `CmdBLTU:begin
            if ((reg1_to_ex)<(reg2_to_ex)) begin
                branch_or_not=`True;
                branch_address=pc_in+imm_in;                 
            end 
        end           
        `CmdBGEU: begin
            if ((reg1_to_ex)>=(reg2_to_ex)) begin
                branch_or_not=`True;
                branch_address=pc_in+imm_in;                 
            end 
        end          
        `CmdLB:          
        `CmdLH:          
        `CmdLW:          
        `CmdLBU:          
        `CmdLHU:          
        `CmdSB:          
        `CmdSH:          
        `CmdSW:          
        `CmdADDI:          
        `CmdSLTI:          
        `CmdSLTIU:          
        `CmdXORI:          
        `CmdORI:          
        `CmdANDI:          
        `CmdSLLI:          
        `CmdSRLI:           
        `CmdSRAI:          
        `CmdADD:          
        `CmdSUB:          
        `CmdSLL:          
        `CmdSLT:          
        `CmdSLTU:          
        `CmdXOR:          
        `CmdSRL:          
        `CmdSRA:          
        `CmdOR:          
        `CmdAND:          
    endcase

    end
        
    
    
end

endmodule //EX