`include "C:\Users\18303\Desktop\cpu\CPU_ACM_2021\riscv\src\define.v"
module pc (
    input  wire     clk_in,
    input  wire     rst_in,
    input  wire     rdy_in, 
    input  wire[5:0] stall_in,

    output reg [`InstAddrBus]    pc_out,
    output reg ce
);
always @(posedge clk_in) begin
    if (rst_in==`RstEnable ) begin
        ce<=`ChipDisable;
    end
    else
        begin
            ce<=`ChipEnable;
        end
end
always @(posedge clk_in) begin
    if (ce==`ChipEnable) begin
        if(stall_in[0]==1&&rdy_in==1) begin
            pc_out<=pc_out+4'h4;
        end
        else begin
            
        end
        
    end
    else
        begin
        pc_out<=`ZeroWorld; 
        end
    end
endmodule //pc