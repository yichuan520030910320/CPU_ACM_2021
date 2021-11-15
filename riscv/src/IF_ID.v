`include "C:\Users\18303\Desktop\cpu\CPU_ACM_2021\riscv\src\define.v"
module IF_ID (
    input  wire                 clk_in,
    input wire rst_in,
    input  wire     rdy_in, 
    //from stall ctrl
    input  wire[5:0] stall_in,
    //from ex
    input  wire branch_or_not,

    //from if
    input wire [`InstAddrBus] input_pc,
    input  wire[`InstDataBus] input_instru,
    //to id
    output reg[`InstAddrBus] output_pc,
    output reg[`InstDataBus] output_instru 
);
always @(posedge clk_in ) begin
    if (rst_in==`Rstdisable) begin
        if (branch_or_not==1) begin
            output_pc<=`ZeroWorld;
            output_instru<=`ZeroWorld; 
        end
        else if (stall_in[1]==1&&stall_in[2]==0) begin
            output_pc<=`ZeroWorld;
            output_instru<=`ZeroWorld;
        end else if(stall_in[1]==0&&rdy_in==1) begin
            output_pc <=input_pc;
            output_instru<=input_instru;
        end  
        //otherwise the Sequential circuit contain the original state     
    end
    else
        begin
            output_pc<=`ZeroWorld;
            output_instru<=`ZeroWorld;
        end
end
endmodule //IF_ID