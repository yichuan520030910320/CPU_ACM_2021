`timescale 1ns/1ps


module EX (


    //from id_ex
    input  wire rst_in, 
    input wire branch_predicate_or_not_in,
    input wire[`RegBus] reg1_to_ex,
    input wire[`RegBus] reg2_to_ex,
    input wire[`RegAddrBus] rsd_to_ex,
    input wire write_rsd_or_not_to_ex,
    input wire[`Cmd_Typebus] cmdtype_to_exe,    
    input wire[`InstAddrBus] pc_in,
    input  wire[`Immbus] imm_in,
    //to ex_mem
    output reg[`RegAddrBus] rsd_addr_to_write,
    output reg[`RegBus] rsd_data,
    output reg write_rsd_or_not,


    output reg branch_or_not,
    output reg[`InstAddrBus] branch_address,
    output reg branch_to_stall_pipline,

    //to btb&bht
    output reg if_the_instru_is_branch,

    output reg[`Dataaddress] mem_addr,
    output reg[`Cmd_Typebus] cmdtype_out, 
    output reg[31:0] mem_val_out_for_store,

    //to btb
output reg[31:0] pc_out_to_btb,
output reg[31:0] pc_target_to_btb,
//from btb
input wire[31:0] predict_pc,


    //forward to id
    output  reg isloading_ex,
    output  reg ex_forward_id_o,
    output  reg[`RegBus] ex_forward_data_o,
    output  reg[`RegAddrBus] ex_forward_addr_o  
);
reg [31:0]branch_address_;
always @(*) begin
    if_the_instru_is_branch=0;
    rsd_addr_to_write=5'h0;
    rsd_data=0;
    write_rsd_or_not=`False;
    branch_or_not=`False;
    mem_addr=`ZeroWorld;
    ex_forward_id_o=`False;
    isloading_ex=0;
    ex_forward_addr_o=0;
    ex_forward_data_o=0;  
    cmdtype_out=cmdtype_to_exe;  
    mem_val_out_for_store=0;
    pc_target_to_btb=0;
    pc_out_to_btb=0;
    branch_to_stall_pipline=0;
    if (rst_in==`RstEnable)begin
        
    end
    else 
    begin
        pc_out_to_btb=pc_in;
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
            branch_address_=pc_in+imm_in;  
            pc_target_to_btb=branch_address_;  
            if_the_instru_is_branch=1; 
        end          
        `CmdJALR:begin
            write_rsd_or_not=`True;
            rsd_data=4+pc_in;
            rsd_addr_to_write=rsd_to_ex;
            branch_or_not=`True;
            branch_address_=(reg1_to_ex+imm_in)&~1;
            pc_target_to_btb=branch_address_;    
            if_the_instru_is_branch=1; 


        end          
        `CmdBEQ:begin       
            if_the_instru_is_branch=1; 

            if (reg1_to_ex==reg2_to_ex) begin
                branch_or_not=`True;
                branch_address_=pc_in+imm_in;
                pc_target_to_btb=branch_address_;  

            end
            
        end          
        `CmdBNE: begin  
            if_the_instru_is_branch=1; 

            if (reg1_to_ex!=reg2_to_ex) begin
                branch_or_not=`True;
                branch_address_=pc_in+imm_in;         
                pc_target_to_btb=branch_address_; 


            end     
            //$display("reg1_to_ex: %h",reg1_to_ex," reg2_to_ex : %h",reg2_to_ex," barch addr:%h ",branch_address," imm :%h ",imm_in,"  pc_in :%h",pc_in);         
        end           
        `CmdBLT: begin
            if_the_instru_is_branch=1; 

            if ($signed(reg1_to_ex)<$signed(reg2_to_ex)) begin
                branch_or_not=`True;
                branch_address_=pc_in+imm_in;      
                pc_target_to_btb=branch_address_;  


            end 
        end              
        `CmdBGE: begin
            if_the_instru_is_branch=1; 

            if ($signed(reg1_to_ex)>=$signed(reg2_to_ex)) begin
                branch_or_not=`True;
                branch_address_=pc_in+imm_in;     
                pc_target_to_btb=branch_address_;  


            end 
        end            
        `CmdBLTU:begin
            if_the_instru_is_branch=1; 

            if ((reg1_to_ex)<(reg2_to_ex)) begin
                branch_or_not=`True;
                branch_address_=pc_in+imm_in;   
                pc_target_to_btb=branch_address_;   


            end 
        end           
        `CmdBGEU: begin
            if_the_instru_is_branch=1; 

            if ((reg1_to_ex)>=(reg2_to_ex)) begin
                branch_or_not=`True;
                branch_address_=pc_in+imm_in;  
                pc_target_to_btb=branch_address_;  

            end 
        end          
        `CmdLB,`CmdLH,`CmdLW,`CmdLBU,`CmdLHU:begin
            mem_addr=reg1_to_ex+imm_in;   
            write_rsd_or_not=`True;
            rsd_addr_to_write=rsd_to_ex;            
        end                                 
        `CmdSB,          
        `CmdSH,          
        `CmdSW:begin
            mem_addr=reg1_to_ex+imm_in;   
            mem_val_out_for_store=reg2_to_ex;        
        end          
        `CmdADDI:    begin
            write_rsd_or_not=`True;
            rsd_addr_to_write=rsd_to_ex;           
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
            rsd_data=reg1_to_ex<<imm_in[4:0];            
        end             
        `CmdSRLI:begin
            write_rsd_or_not=`True;
            rsd_addr_to_write=rsd_to_ex;
            rsd_data=reg1_to_ex>>imm_in[4:0];   
            //$display("rsd_data :",rsd_data);         
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


always @(*) begin
    branch_to_stall_pipline=0;
    branch_address=0;
    if (rst_in==`RstEnable)begin
        
    end
    else 
    begin
    case (cmdtype_to_exe)
    `CmdJAL,`CmdJALR,`CmdBEQ,`CmdBNE,`CmdBLT,`CmdBGE,`CmdBLTU,`CmdBGEU:begin
            if(branch_or_not==`True&&predict_pc!=branch_address_)begin
                branch_to_stall_pipline=1;
                branch_address=branch_address_;
            end
            if(branch_or_not==`False&&predict_pc!=pc_in+4)begin
                branch_to_stall_pipline=1;   
                branch_address=pc_in+4;
            end
        
    end
    default:begin
            
    end
    endcase
    // $display($time,"predict_pc  %h",predict_pc);
    // $display($time,"branchaddr  %h",branch_address);
    end


end

endmodule //EX