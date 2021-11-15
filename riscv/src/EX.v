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
    output reg[`InstAddrBus] branch_address,
    output reg[`Dataaddress] mem_addr,
    output reg mem_read_or_not,
    output reg[`Cmd_Typebus] cmdtype_out,  


    

//forward
    output  reg isloading_ex,
    output  reg ex_forward_id_o,
    output  reg[`RegBus] ex_forward_data_o,
    output  reg[`RegAddrBus] ex_forward_addr_o  
);
always @(*) begin
    rsd_addr_to_write=5'h0;
    rsd_data=0;
    write_rsd_or_not=`False;
    branch_or_not=`False;
    branch_address=0;
    mem_addr=`ZeroWorld;
    mem_read_or_not=`False;
    ex_forward_id_o=`False;
    isloading_ex=0;
    ex_forward_addr_o=0;
    ex_forward_data_o=0;  
    cmdtype_out=cmdtype_to_exe;  
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
        `CmdLB,`CmdLH,`CmdLW,`CmdLBU,`CmdLHU:begin
            mem_addr=reg1_to_ex+imm_in; 
            mem_read_or_not=`True;            
        end                                 
        `CmdSB,          
        `CmdSH,          
        `CmdSW:begin
            mem_addr=reg1_to_ex+imm_in;
            mem_read_or_not=`True;            
        end          
        `CmdADDI:    begin
            write_rsd_or_not=`True;
            rsd_data=reg1_to_ex+imm_in;
            
        end      
        `CmdSLTI:
        begin
            write_rsd_or_not=`True;
            rsd_addr_to_write=rsd_to_ex;
            rsd_data=0;            
            if ($signed(reg1_to_ex)<$signed(imm_in)) begin
                rsd_data=1;                
            end            
        end          
        `CmdSLTIU:
        begin
            write_rsd_or_not=`True;
            rsd_addr_to_write=rsd_to_ex;
            rsd_data=0;            
            if (reg1_to_ex<(imm_in)) begin
                rsd_data=1;                
            end            
        end                  
        `CmdXORI:begin
            write_rsd_or_not=`True;
            rsd_addr_to_write=rsd_to_ex;
            rsd_data=reg1_to_ex^imm_in;            
        end          
        `CmdORI:begin
            write_rsd_or_not=`True;
            rsd_addr_to_write=rsd_to_ex;
            rsd_data=reg1_to_ex|imm_in;            
        end          
        `CmdANDI:begin
            write_rsd_or_not=`True;
            rsd_addr_to_write=rsd_to_ex;
            rsd_data=reg1_to_ex&imm_in;            
        end                
        `CmdSLLI:begin
            write_rsd_or_not=`True;
            rsd_addr_to_write=rsd_to_ex;
            rsd_data=reg1_to_ex<<imm_in;            
        end             
        `CmdSRLI:begin
            write_rsd_or_not=`True;
            rsd_addr_to_write=rsd_to_ex;
            rsd_data=reg1_to_ex>>imm_in[4:0];            
        end            
        `CmdSRAI:begin
            write_rsd_or_not=`True;
            rsd_addr_to_write=rsd_to_ex;
            rsd_data=$signed(reg1_to_ex)>>imm_in[4:0];             
        end          
        `CmdADD: 
        begin
            write_rsd_or_not=`True;
            rsd_addr_to_write=rsd_to_ex;
            rsd_data=reg1_to_ex+reg2_to_ex;             
        end            
        `CmdSUB: begin
            write_rsd_or_not=`True;
            rsd_addr_to_write=rsd_to_ex;
            rsd_data=reg1_to_ex-reg2_to_ex;             
        end            
        `CmdSLL:  begin
            write_rsd_or_not=`True;
            rsd_addr_to_write=rsd_to_ex;
            rsd_data=reg1_to_ex<<reg2_to_ex;              
        end           
        `CmdSLT: begin
            write_rsd_or_not=`True;
            rsd_addr_to_write=rsd_to_ex;
            rsd_data=0;
            if ($signed(reg1_to_ex)<$signed(reg2_to_ex)) begin
                rsd_data=1;
            end            
        end         
        `CmdSLTU:
        begin
            write_rsd_or_not=`True;
            rsd_addr_to_write=rsd_to_ex;
            rsd_data=0;            
            if (reg1_to_ex<reg2_to_ex) begin
                rsd_data=1;                
            end            
        end                   
        `CmdXOR: 
        begin
            write_rsd_or_not=`True;
            rsd_addr_to_write=rsd_to_ex;
            rsd_data=reg1_to_ex^reg2_to_ex;             
        end          
        `CmdSRL:begin
            write_rsd_or_not=`True;
            rsd_addr_to_write=rsd_to_ex;
            rsd_data=reg1_to_ex>>reg2_to_ex[4:0];
            
        end          
        `CmdSRA:  
        begin
            write_rsd_or_not=`True;
            rsd_addr_to_write=rsd_to_ex;
            rsd_data=$signed(reg1_to_ex)>>reg2_to_ex[4:0];
            
        end         
        `CmdOR:begin
            write_rsd_or_not=`True;
            rsd_addr_to_write=rsd_to_ex;
            rsd_data=reg1_to_ex|reg2_to_ex;             
        end          
        `CmdAND: begin
            write_rsd_or_not=`True;
            rsd_addr_to_write=rsd_to_ex;
            rsd_data=reg1_to_ex&reg2_to_ex;             
        end
        default:begin
            
        end

    endcase

    end

    if (write_rsd_or_not==`True) begin
        if (cmdtype_to_exe==`CmdLB||cmdtype_to_exe==`CmdLH||cmdtype_to_exe==`CmdLW||cmdtype_to_exe==`CmdLBU||cmdtype_to_exe==`CmdLHU) begin
            isloading_ex=1;
        end
        ex_forward_id_o=`True;
        ex_forward_addr_o=rsd_to_ex;
        ex_forward_data_o=rsd_data;        
    end
        
    
    
end

endmodule //EX