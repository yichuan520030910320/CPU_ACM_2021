`include "C:\Users\18303\Desktop\cpu\CPU_ACM_2021\riscv\src\define.v"
module EX_MEM (
    input   wire    clk_in,
    input   wire    rst_in,
    input  wire     rdy_in, 

    input  wire[5:0] stall_in,


    input wire[`RegAddrBus] rsd_addr_to_write,
    input wire[`RegBus] rsd_data,
    input wire write_rsd_or_not,
    input wire branch_or_not,
    input wire[`InstAddrBus] branch_address,
    input wire[`Dataaddress] mem_addr,
    input wire mem_read_or_not,

    output reg[`RegAddrBus] rsd_addr_out,
    output reg[`RegBus] rsd_data_out,
    output reg write_rsd_or_not_out,
    output reg branch_or_not_out,
    output reg[`InstAddrBus] branch_address_out,
    output reg[`Dataaddress] mem_addr_out,
    output reg mem_read_or_not_out   
);

always @(posedge clk_in) begin
    if (rst_in==`RstEnable) begin
        rsd_addr_out=`ZeroWorld;
        rsd_data_out=`ZeroWorld;
        write_rsd_or_not_out=`False;
        branch_or_not_out=`False;
        branch_address_out=`ZeroWorld;
        mem_addr_out=`ZeroWorld;
        mem_read_or_not_out=`False;
    end
    else
        begin
            if(stall_in[3]==1&&stall_in[4]==0) begin
                rsd_addr_out=`ZeroWorld;
                rsd_data_out=`ZeroWorld;
                write_rsd_or_not_out=`False;
                branch_or_not_out=`False;
                branch_address_out=`ZeroWorld;
                mem_addr_out=`ZeroWorld;
                mem_read_or_not_out=`False;                
            end
            else if(stall_in[3]==0&&rdy_in==1)
            begin
                rsd_addr_out=rsd_addr_to_write;
                rsd_data_out=rsd_data;
                write_rsd_or_not_out=write_rsd_or_not;
                branch_or_not_out=branch_or_not;
                branch_address_out=branch_address;
                mem_addr_out=mem_addr;
                mem_read_or_not_out=mem_read_or_not;      
            end               
        end    
end
endmodule //EX_MEM