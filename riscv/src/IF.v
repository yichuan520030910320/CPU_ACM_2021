`include "/mnt/c/Users/18303/Desktop/cpu/CPU_ACM_2021/riscv/src/define.v"
module IF (
    input  wire rst_in,


    //from pc
    input wire[31:0] pc_in,

    //to if_id
    output reg[31:0] pc_out,
    output reg[31:0] instr_out,




    //to stallctrl
    output reg stall_from_if,

    //from mem ctrl
    input wire if_load_done,
    input  wire[1:0] mem_ctrl_busy_state,
    input wire[31:0] mem_ctrl_read_in,

    //to mem ctrl
    output reg read_or_not,  
    output  reg[31:0] intru_addr
);
always @(*)
begin
    read_or_not=0;
    intru_addr=0;
    pc_out=0;
    instr_out=0;
    stall_from_if=0;
    if (rst_in==1) begin
        
    end
    else if(if_load_done==1) begin
        instr_out=mem_ctrl_read_in;
        pc_out=pc_in;       
    end else
        begin
            if( mem_ctrl_busy_state[0]==1) begin
                intru_addr=pc_in;  
                stall_from_if=1;             
            end
            else begin
                stall_from_if=1;
                read_or_not=1;
                intru_addr=pc_in;
            end
            
        end
end

endmodule //IF