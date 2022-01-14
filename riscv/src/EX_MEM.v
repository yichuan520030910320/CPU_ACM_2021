
module EX_MEM (
    //debug add
    input  wire[31:0] store_data,
    output reg[31:0] store_data_out, 

    input   wire    clk_in,
    input   wire    rst_in,
    input  wire     rdy_in, 
    //from stall ctrl
    input  wire[5:0] stall_in,

    //from ex
    input wire[`RegAddrBus] rsd_addr_to_write,
    input wire[`RegBus] rsd_data,
    input wire write_rsd_or_not,
    input wire[`Dataaddress] mem_addr,
    input wire[`Cmd_Typebus] cmdtype,    
    //to mem
    output reg[`Cmd_Typebus] cmdtype_out,    
    output reg[`RegAddrBus] rsd_addr_out,
    output reg[`RegBus] rsd_data_out,
    output reg write_rsd_or_not_out,
    output reg[`Dataaddress] mem_addr_out

);

always @(posedge clk_in) begin
    if (rst_in==`RstEnable) begin
        rsd_addr_out<=`ZeroWorld;
        rsd_data_out<=`ZeroWorld;
        write_rsd_or_not_out<=`False;
        mem_addr_out<=`ZeroWorld;
        store_data_out<=0;
        cmdtype_out<=0;


    end
    else
        begin
            if(stall_in[3]==1&&stall_in[4]==0) begin
                rsd_addr_out<=`ZeroWorld;
                rsd_data_out<=`ZeroWorld;
                write_rsd_or_not_out<=`False;
                mem_addr_out<=`ZeroWorld;
                store_data_out<=0;
                cmdtype_out<=0;
            end
            else if(stall_in[3]==0&&rdy_in==1)
            begin
                rsd_addr_out<=rsd_addr_to_write;
                rsd_data_out<=rsd_data;
                write_rsd_or_not_out<=write_rsd_or_not;
                mem_addr_out<=mem_addr;
                store_data_out<=store_data;
                cmdtype_out<=cmdtype;

            end               
        end    
end
endmodule //EX_MEM