`include "C:\Users\18303\Desktop\cpu\CPU_ACM_2021\riscv\src\define.v"
module MEM (
    input  wire rst_in,

    input wire [`RegAddrBus] input_rd_addr,
    input wire [`RegBus] input_rd_data,
    input  wire write_or_not,

    output reg [`RegAddrBus] out_rd_addr,
    output reg [`RegBus] out_rd_data,
    output reg out_write_or_not,
    output  reg mem_forward_id_o,
    output  reg[`RegBus] mem_forward_data_o,
    output  reg[`RegAddrBus] mem_forward_addr_o     
);
always @(*)begin
    out_rd_addr=0;
    out_rd_data=0;
    out_write_or_not=`False;
    mem_forward_id_o=`False;
    mem_forward_addr_o=0;
    mem_forward_data_o=0;  
    if (rst_in==`RstEnable) begin
        
    end else begin
        out_rd_addr=input_rd_addr;
        out_rd_data=input_rd_data;
        out_write_or_not=write_or_not;       
    end

    if (out_write_or_not==`True) begin
        mem_forward_id_o=`True;
        mem_forward_addr_o=out_rd_addr;
        mem_forward_data_o=out_rd_data;  
    end
end

endmodule //MEM