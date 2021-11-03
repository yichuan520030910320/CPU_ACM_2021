`include "C:\Users\18303\Desktop\cpu\CPU_ACM_2021\riscv\src\define.v"
module regfile (
    input  wire clk_in,
    input wire rst_in,


    input  wire write_or_not,
    input wire[`RegAddrBus] writeaddr,
    input wire[`RegBus] writedata,

    input  wire read1_or_not,
    input  wire[`RegAddrBus] readaddr1,
    output  reg[`RegBus] read1data,

    input  wire read2_or_not,
    input  wire[`RegAddrBus] readaddr2,
    output  reg[`RegBus] read2data

);
reg [`RegBus]regs [0:31];
always @(posedge clk_in ) begin
    if (rst_in==`Rstdisable) begin
        if ((write_or_not==`Writeable)&&(writeaddr!=(5'h0))) begin
            regs[writeaddr]<=writedata;
        end
    end
    
end
always @(*) begin
    if (rst_in==`RstEnable) begin
        read1data<=`ZeroWorld;
    end
    else if(write_or_not==`Writeable&&readaddr1==writeaddr&&read1_or_not==`Readable) begin
        read1data<=writedata;
    end
    else if(read1_or_not==`Readable) begin
        read1data<=regs[readaddr1];
    end
    else
        begin
            read1data<=`ZeroWorld;
        end
    
end

always @(*) begin
    if (rst_in==`RstEnable) begin
        read1data<=`ZeroWorld;
    end
    else if(write_or_not==`Writeable&&readaddr2==writeaddr&&read2_or_not==`Readable) begin
        read2data<=writedata;
    end
    else if(read1_or_not==`Readable) begin
        read2data<=regs[readaddr2];
    end
    else
        begin
            read2data<=`ZeroWorld;
        end
    
end
endmodule //regfile