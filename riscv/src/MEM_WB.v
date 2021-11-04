`include "C:\Users\18303\Desktop\cpu\CPU_ACM_2021\riscv\src\define.v"
module MEM_WB (
    input   wire    clk_in,
    input   wire    rst_in,

    input wire [`RegAddrBus] mem_reg_addr,
    input wire [`RegBus] mem_reg_data,
    input  wire if_write,

    output reg[`RegAddrBus] mem_reg_addr_out, 
    output reg [`RegBus] mem_reg_data_out,
    output  reg if_write_out
    
);
always @(posedge clk_in ) begin
    if(rst_in==`RstEnable) begin
        mem_reg_addr_out=`ZeroWorld;
        mem_reg_addr_out=`ZeroWorld;
        if_write_out=`False;       
    end
    else begin
        mem_reg_addr_out=mem_reg_addr;
        mem_reg_addr_out=mem_reg_data;
        if_write_out=if_write;          
    end
    
end

endmodule //MEM_WB