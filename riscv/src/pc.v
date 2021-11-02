`include "C:\Users\18303\Desktop\cpu\CPU_ACM_2021\riscv\src\define.v"
module pc (
    input  wire     clk_in,
    input  wire     rst_in,

    
    output reg [`InstAddrBus]    pc_out,
    output reg ce
);
always @(posedge clk_in) begin
    if (rst_in==`RstEnable1 ) begin
        ce=`ChipEnable;
    end
    else
        begin
            ce=`ChipDisable;
        end
end
always @(posedge clk_in) begin
    if (ce==`ChipEnable) begin
        pc_out<=pc_out+4'h4;
    end
    else
        begin
           pc_out=`ZeroWorld; 
        end
    end
endmodule //pc