`include "C:\Users\18303\Desktop\cpu\CPU_ACM_2021\riscv\src\define.v"
module IF_ID (
    input  wire                 clk_in,
    input wire rst_in,

    input wire [`InstAddrBus] input_pc,
    input  wire[`InstDataBus] input_instru,

    output reg[`InstAddrBus] output_pc,
    output reg[`InstDataBus] output_instru 
);
always @(posedge clk_in ) begin
    if (rst_in==`Rstdisable) begin
        output_pc <=input_pc;
        output_instru<=input_instru;
    end
    else
        begin
            output_pc<=`ZeroWorld;
            output_instru<=`ZeroWorld;
        end
end
endmodule //IF_ID