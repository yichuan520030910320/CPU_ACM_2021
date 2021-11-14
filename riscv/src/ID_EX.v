`include "C:\Users\18303\Desktop\cpu\CPU_ACM_2021\riscv\src\define.v"
module ID_EX (
    input   wire    clk_in,
    input   wire    rst_in,
    input  wire     rdy_in, 
    input  wire[5:0] stall_in,


    input wire [`InstAddrBus] input_pc,
    input wire[`RegBus] reg1_from_id,
    input wire[`RegBus] reg2_from_id,
    input wire[`RegAddrBus] rsd_from_id,
    input wire write_rsd_or_not_from_id,
    input wire[`Cmd_Typebus] cmdtype_from_id,
    input wire[`InstAddrBus] pc_in,
    input wire[`Immbus] imm_in,


    output reg[`RegBus] reg1_to_ex,
    output reg[`RegBus] reg2_to_ex,
    output reg[`RegAddrBus] rsd_to_ex,
    output reg write_rsd_or_not_to_ex,
    output reg[`Cmd_Typebus] cmdtype_to_exe,    
    output reg[`InstAddrBus] pc_out   ,
    output  reg[`Immbus] imm_out

);

always @(posedge clk_in) begin
    if(rst_in==`RstEnable)begin
        reg1_to_ex<=`ZeroWorld;
        reg2_to_ex<=`ZeroWorld;
        rsd_to_ex<=5'h0;
        write_rsd_or_not_to_ex<=`False;
        cmdtype_to_exe<=6'h0;
        pc_out<=`ZeroWorld; 
        imm_out<=`ZeroWorld;      
    end
    else begin
        if(stall_in[2]==1&&stall_in[3]==0) begin
        reg1_to_ex<=`ZeroWorld;
        reg2_to_ex<=`ZeroWorld;
        rsd_to_ex<=5'h0;
        write_rsd_or_not_to_ex<=`False;
        cmdtype_to_exe<=6'h0;
        pc_out<=`ZeroWorld; 
        imm_out<=`ZeroWorld;  
        end
        else if (stall_in[2]==0&&rdy_in==1) begin
        reg1_to_ex<=reg1_from_id;
        reg2_to_ex<=reg2_from_id;
        rsd_to_ex<=rsd_from_id;
        write_rsd_or_not_to_ex<=write_rsd_or_not_from_id;
        cmdtype_to_exe<=cmdtype_from_id;
        pc_out<=pc_in;
        imm_out<=imm_in;
        end
        
        end
end
endmodule //ID_EX