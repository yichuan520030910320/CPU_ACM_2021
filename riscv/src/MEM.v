`include "C:\Users\18303\Desktop\cpu\CPU_ACM_2021\riscv\src\define.v"
module MEM (
    input  wire rst_in,

    input wire [`RegAddrBus] input_rd_addr,
    input wire [`RegBus] input_rd_data,
    input  wire write_or_not,

    output reg [`RegAddrBus] out_rd_addr,
    output reg [`RegBus] out_rd_data,
    output reg out_write_or_not



    
);
always @(*)begin
    out_rd_addr=0;
    out_rd_data=0;
    out_write_or_not=`False;
    if (rst_in==`RstEnable) begin
        
    end else begin
        out_rd_addr=input_rd_addr;
        out_rd_data=input_rd_data;
        out_write_or_not=write_or_not;
        
    end
end

endmodule //MEM